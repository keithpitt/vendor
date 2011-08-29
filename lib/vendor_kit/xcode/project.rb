require 'json'

module VendorKit::XCode

  class Project

    attr_reader :object_version
    attr_reader :archive_version
    attr_reader :objects
    attr_reader :root_object

    def initialize(project_folder)

      pbxproject = ::File.join(project_folder, "project.pbxproj")

      parsed = JSON.parse(`plutil -convert json -o - "#{pbxproject}"`)

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

  end

end
