require 'json'

module Vendor::XCode

  class Project

    require 'fileutils'

    attr_reader :name
    attr_reader :object_version
    attr_reader :archive_version
    attr_reader :objects
    attr_reader :root_object

    attr_accessor :dirty

    def initialize(project_folder)
      @project_folder = project_folder
      @pbxproject = ::File.join(project_folder, "project.pbxproj")
      @name = File.basename(project_folder).split(".").first
      @dirty = false

      reload
    end

    def reload
      # We switch between our custom PList converter and the JSON format
      # because the custom implementation isn't very reliable. We use it mainly
      # so the gem can run on systems that don't have plutil installed (like our
      # CI server). The plutil app is far more reliable.
      if RUBY_PLATFORM !=~ /darwin/ || ENV['PARSER'] == 'custom'
        contents = File.readlines(@pbxproject).join("\n")
        parsed = Vendor::Plist.parse_ascii(contents)
      else
        parsed = JSON.parse(`plutil -convert json -o - "#{@pbxproject}"`)
      end

      @object_version = parsed['objectVersion'].to_i
      @archive_version = parsed['archiveVersion'].to_i

      @objects_by_id = {}

      @objects = parsed['objects'].map do |id, attributes|
        klass = Vendor::XCode::Proxy.const_get(attributes['isa'])

        @objects_by_id[id] = klass.new(:project => self, :id => id, :attributes => attributes)
      end

      @objects.each { |object| object.send(:after_initialize) }

      @root_object = @objects_by_id[parsed['rootObject']]
    end

    def find_object(id)
      @objects_by_id[id]
    end

    def find_target(name)
      root_object.targets.find { |x| x.name == name }
    end

    def find_group(path)
      current = root_object.main_group

      path.split("/").each do |name|
        current = current.children.find { |x| x.name == name }
        return nil unless current
      end

      current
    end

    def create_group(path)
      current = root_object.main_group

      path.split("/").each do |name|
        group = current.children.find { |x| x.name == name }

        unless group
          group = Vendor::XCode::Proxy::PBXGroup.new(:project => self,
                                                          :id => Vendor::XCode::Proxy::Base.generate_id,
                                                  :attributes => { 'path' => name, 'sourceTree' => '<group>', 'children' => [] })

          @objects_by_id[group.id] = group

          # This is hacky
          current.attributes['children'] << group.id
        end

        current = group
      end

      # Mark as dirty
      @dirty = true

      current
    end

    def remove_group(path)
      group = find_group(path)

      # If we have the group
      if group

        # Remove the children from the file system
        group.children.each do |child|
          if child.group? # Is it a group?
            remove_group child.full_path # Recursivley remove the child group
          elsif child.file? # Or a file
            file = File.expand_path(File.join(@project_folder, "..", child.full_path))

            # Remove the file from the filesystem
            if File.exist?(file)
              FileUtils.rm file
            end
          else
            Vendor.ui.error "Couldn't remove object: #{child}"
          end

          # Remove the file from the parent
          child.parent.attributes['children'].delete child.id
        end

        # Remove the group from the parent
        group.parent.attributes['children'].delete group.id

        # Mark as dirty
        @dirty = true

      else
        false
      end
    end

    def add_file(options)
      require_options options, :path, :file

      # Ensure file exists
      raise StandardError.new("Could not find file `#{options[:file]}`") unless File.exists?(options[:file])

      # Ensure the path exists
      path = File.join(@project_folder, "..", options[:path])
      FileUtils.mkdir_p path

      # Copy the file
      name = File.basename(options[:file])
      FileUtils.cp options[:file], File.join(path, name)

      # Add the file to XCode
      group = create_group(options[:path])
      relative_path = File.join(options[:path], name)
      file_type = Vendor::XCode::Proxy::PBXFileReference.file_type_from_extension(File.extname(options[:file]))

      file = Vendor::XCode::Proxy::PBXFileReference.new(:project => self,
                                                             :id => Vendor::XCode::Proxy::Base.generate_id,
                                                     :attributes => { 'path' => name, 'lastKnownFileType' => file_type, 'sourceTree' => '<group>' })

      group.attributes['children'] << file.id

      # Mark as dirty
      @dirty = true

      @objects_by_id[file.id] = file
    end

    def to_ascii_plist
      plist = { :archiveVersion => archive_version,
                :classes => {},
                :objectVersion => object_version,
                :objects => @objects_by_id,
                :rootObject => @root_object.id }.to_ascii_plist

      "// !$*UTF8*$!\n" << plist
    end

    def save
      open(@pbxproject, 'w+') do |f|
        f << to_ascii_plist
      end if valid?

      # Not dirty anymore
      @dirty = false
    end

    def dirty?
      @dirty
    end

    def valid?
      begin
        # Try and parse the plist again. If it parses, then we've
        # got valid syntax, if it fails, it will raise a parse error. We
        # know we've done something bad at this point.
        Vendor::Plist.parse_ascii(to_ascii_plist)

        true
      rescue Vendor::Plist::AsciiParser::ParseError => e
        Vendor.ui.error "There was an error converting the XCode project back to a Plist"
        Vendor.ui.error e.inspect

        false
      end
    end

    private

      def require_options(options, *keys)
        keys.each { |k| raise StandardError.new("Missing :#{k} option") unless options[k] }
      end

  end

end
