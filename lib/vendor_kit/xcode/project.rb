require 'json'

module VendorKit::XCode

  class Project

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
        parsed = VendorKit::Plist.parse_ascii(contents)
      else
        parsed = JSON.parse(`plutil -convert json -o - "#{@pbxproject}"`)
      end

      @object_version = parsed['objectVersion'].to_i
      @archive_version = parsed['archiveVersion'].to_i

      @objects_by_id = {}

      @objects = parsed['objects'].map do |id, attributes|
        klass = VendorKit::XCode::Objects.const_get(attributes['isa'])

        @objects_by_id[id] = klass.new(:project => self, :id => id, :attributes => attributes)
      end

      @root_object = @objects_by_id[parsed['rootObject']]
    end

    def find_object(id)
      @objects_by_id[id]
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

  end

end
