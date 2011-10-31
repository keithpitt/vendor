require 'json'

module Vendor::XCode

  class Project

    require 'fileutils'

    attr_reader :object_version
    attr_reader :archive_version
    attr_reader :objects
    attr_reader :root_object

    def initialize(project_folder)
      @project_folder = project_folder
      @pbxproject = ::File.join(project_folder, "project.pbxproj")

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

      @root_object = @objects_by_id[parsed['rootObject']]
    end

    def find_object(id)
      @objects_by_id[id]
    end

    def find_target(name)
      root_object.targets.find { |x| x.name == name }
    end

    def find_and_make_group(path)
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

      current
    end

    def add_file(options)
      require_options options, :targets, :path, :file

      # Ensure file exists
      raise StandardError.new("Could not find file `#{options[:file]}`") unless File.exists?(options[:file])

      # Ensure the path exists
      path = File.join(@project_folder, "..", options[:path])
      FileUtils.mkdir_p path

      # Copy the file
      name = File.basename(options[:file])
      FileUtils.cp options[:file], File.join(path, name)

      # Add the file to XCode
      group = find_and_make_group(options[:path])
      relative_path = File.join(options[:path], name)
      file_type = Vendor::XCode::Proxy::PBXFileReference.file_type_from_extension(File.extname(options[:file]))

      file = Vendor::XCode::Proxy::PBXFileReference.new(:project => self,
                                                             :id => Vendor::XCode::Proxy::Base.generate_id,
                                                             :attributes => { 'path' => name, 'lastKnownFileType' => file_type, 'sourceTree' => '<group>' })

      group.attributes['children'] << file.id

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
      end
    end

    private

      def require_options(options, *keys)
        keys.each { |k| raise StandardError.new("Missing :#{k} option") unless options[k] }
      end

  end

end
