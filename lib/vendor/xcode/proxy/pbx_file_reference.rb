module Vendor::XCode::Proxy

  class PBXFileReference < Vendor::XCode::Proxy::Base

    SUPPORTED_FILE_TYPES = %w(png jpg h m bundle framework a strings plist)

    reference :file_ref

    def name
      read_attribute :path
    end

    def file?
      true
    end

    def full_path
      parts = []
      current = self

      while current
        parts.push current.path if current.respond_to?(:path) && !current.path.nil?
        current = current.parent
      end

      parts.reverse.join("/")
    end

    def self.file_type_from_extension(extension)
      case extension
        when /.(png|jpg)/ then "image.#{$1}"
        when ".h"         then "sourcecode.c.h"
        when ".m"         then "sourcecode.c.objc"
        when ".bundle"    then "wrapper.plug-in"
        when ".framework" then "wrapper.framework"
        when ".a"         then "archive.ar"
        when ".strings"   then "text.plist.strings"
        when ".plist"     then "text.plist.xml"
        else "unknown"
      end
    end

  end

end
