module Vendor::XCode::Proxy

  class PBXFileReference < Vendor::XCode::Proxy::Base

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
        when ".h" then "sourcecode.c.h"
        when ".m" then "sourcecode.c.objc"
        else "unknown"
      end
    end

  end

end
