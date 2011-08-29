require 'json'

module VendorKit::XCode

  class Proxy

    attr_reader :object_version
    attr_reader :archive_version

    attr_reader :objects

    def initialize(project_folder)

      pbxproject = ::File.join(project_folder, "project.pbxproj")
      parsed = JSON.parse(`plutil -convert json -o - "#{pbxproject}"`)

      @object_version = parsed['objectVersion'].to_i
      @archive_version = parsed['archiveVersion'].to_i

      @objects = parsed['objects'].map do |id, attributes|
        klass = VendorKit::XCode::Objects.const_get(attributes['isa'])
        klass.new(attributes)
      end

    end

  end

end
