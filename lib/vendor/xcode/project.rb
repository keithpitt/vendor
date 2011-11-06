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

    def find_target(t)
      # Are we already a target?
      if t.kind_of?(Vendor::XCode::Proxy::Base)
        t
      else
        root_object.targets.find { |x| x.name == t }
      end
    end

    def find_group(path)
      current = root_object.main_group

      path.split("/").each do |name|
        current = current.children.find { |x| (x.respond_to?(:name) ? x.name : x.path) == name }
        return nil unless current
      end

      current
    end

    def create_group(path)
      current = root_object.main_group

      path.split("/").each do |name|
        group = current.children.find { |x| (x.respond_to?(:name) ? x.name : x.path) == name }

        unless group
          group = Vendor::XCode::Proxy::PBXGroup.new(:project => self,
                                                          :id => Vendor::XCode::Proxy::Base.generate_id,
                                                  :attributes => { 'path' => name, 'sourceTree' => '<group>', 'children' => [] })

          # Set the parent
          group.parent = current

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

        ids_to_remove = []

        # Remove the children from the file system
        group.children.each do |child|
          if child.group? # Is it a group?
            remove_group child.full_path # Recursivley remove the child group
          elsif child.file? # Or a file
            file = File.expand_path(File.join(@project_folder, "..", child.full_path))

            # Remove the file from the filesystem
            if File.exist?(file)
              FileUtils.rm_rf file
            end
          else
            Vendor.ui.error "Couldn't remove object: #{child}"
          end

          # Remove from the targets (if we can)
          root_object.targets.each { |t| remove_file_from_target(child, t) }

          # Remove the file from the parent
          child.parent.attributes['children'].delete child.id

          # Add the id to the list of stuff to remove. If we do this
          # during the loop, bad things happen - not sure why.
          ids_to_remove << child.id
        end

        # Remove the group from the parent
        group.parent.attributes['children'].delete group.id

        # Add to the list of stuff to remove
        ids_to_remove << group.id

        ids_to_remove.each do |id|
          @objects_by_id.delete id
        end

        # Mark as dirty
        @dirty = true

      else
        false
      end
    end

    def add_framework(framework, options = {})
      # Find targets
      targets = targets_from_options(options)
      Vendor.ui.debug %{Adding #{framework} to targets "#{targets.map(&:name)}"}

      targets.each do |t|
        # Does the framework already exist?
        build_phase = build_phase_for_file("wrapper.framework", t)

        if build_phase
          # Does a framework already exist?
          existing_framework = build_phase.files.map(&:file_ref).find do |file|
            # Some files have names, some done. Framework references
            # have names...
            if file.respond_to?(:name)
              file.name == framework
            end
          end

          # If an existing framework was found, don't add it again
          unless existing_framework
            add_file :targets => t, :file => "System/Library/Frameworks/#{framework}", :path => "Frameworks", :source_tree => :sdkroot
          end
        end
      end
    end

    def add_build_setting(name, value, options = {})
      # Find targets
      targets = targets_from_options(options)

      Vendor.ui.debug %{Adding #{name}=#{value} to targets "#{targets.map(&:name)}"}
    end

    def add_file(options)
      require_options options, :path, :file, :source_tree

      # Ensure file exists if we'nre not using the sdk root source tree.
      # The SDKROOT source tree has a virtual file on the system, so
      # File.exist checks will always return false.
      unless options[:source_tree] == :sdkroot
        raise StandardError.new("Could not find file `#{options[:file]}`") unless File.exists?(options[:file])
      end

      # Find targets
      targets = targets_from_options(options)

      # Create the group
      group = create_group(options[:path])

      # File type
      type = Vendor::XCode::Proxy::PBXFileReference.file_type_from_extension(File.extname(options[:file]))

      # The file name
      name = File.basename(options[:file])

      attributes = {
        'lastKnownFileType' => type,
        'sourceTree' => "<#{options[:source_tree].to_s}>"
      }

      # Handle the different source tree types
      if options[:source_tree] == :group

        # Ensure the path exists on the filesystem
        path = File.join(@project_folder, "..", options[:path])
        FileUtils.mkdir_p path

        # Copy the file
        FileUtils.cp_r options[:file], File.join(path, name)

        # Set the path of the file
        attributes['path'] = name

      elsif options[:source_tree] == :absolute

        # Set the path and the name of the file
        attributes['name'] = name
        attributes['path'] = options[:file]

      elsif options[:source_tree] == :sdkroot

        # Set the path and the name of the framework
        attributes['path'] = options[:file]
        attributes['sourceTree'] = "SDKROOT"

      else

        # Could not handle that option
        raise StandardError.new("Invalid :source_tree option `#{options[:source_tree].to_s}`")

      end

      # Add the file to XCode
      file = Vendor::XCode::Proxy::PBXFileReference.new(:project => self,
                                                             :id => Vendor::XCode::Proxy::Base.generate_id,
                                                     :attributes => attributes)

      # Set the parent
      file.parent = group

      # Add the file id to the groups children
      group.attributes['children'] << file.id

      # Add the file to targets
      targets.each do |t|
        add_file_to_target file, t
      end

      # Mark as dirty
      @dirty = true

      # Add the file to the internal index
      @objects_by_id[file.id] = file
    end

    def remove_file_from_target(file, target)

      # Search through all the build phases for references to the file
      build_files = []
      target.build_phases.each do |phase|
        build_files << phase.files.find_all do |build_file|
          build_file.attributes['fileRef'] == file.id
        end
      end

      # Remove the build files from the references
      build_files.flatten.each do |build_file|
        build_file.parent.attributes['files'].delete build_file.id
        @objects_by_id.delete build_file.id
      end

    end

    def add_file_to_target(file, target)

      build_phase = build_phase_for_file(file.last_known_file_type, target)

      if build_phase

        Vendor.ui.debug "Adding #{file.attributes} to #{target.name} (build_phase = #{build_phase.class.name})"

        # Add the file to XCode
        build_file = Vendor::XCode::Proxy::PBXBuildFile.new(:project => self,
                                                                 :id => Vendor::XCode::Proxy::Base.generate_id,
                                                         :attributes => { 'fileRef' => file.id })

        # Set the parent
        build_file.parent = build_phase

        # Add the file to the internal index
        @objects_by_id[build_file.id] = build_file

        # Add the file to the build phase
        build_phase.attributes['files'] << build_file.id

      end

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

      def build_phase_for_file(file_type, target)
        # Which build phase does this file belong?
        klass = case file_type
          when "sourcecode.c.objc"
            Vendor::XCode::Proxy::PBXSourcesBuildPhase
          when "wrapper.framework"
            Vendor::XCode::Proxy::PBXFrameworksBuildPhase
        end

        if klass
          # Find the build phase
          build_phase = target.build_phases.find { |phase| phase.kind_of?(klass) }
          unless build_phase
            Vendor.ui.error "Could not find '#{klass.name}' build phase for target '#{target.name}'"
            exit 1
          end
          build_phase
        else
          Vendor.ui.debug "Could not find a build phase to add '#{file_type}' files"
          false
        end
      end

      def require_options(options, *keys)
        keys.each { |k| raise StandardError.new("Missing :#{k} option") unless options[k] }
      end

      def targets_from_options(options)
        if options[:targets]
          [ *options[:targets] ].map do |t|
            if t == :all
              root_object.targets
            else
              target = find_target(t)
              raise StandardError.new("Could not find target '#{t}' in project '#{name}'") unless target
              target
            end
          end.flatten.uniq
        else
          root_object.targets
        end
      end

  end

end
