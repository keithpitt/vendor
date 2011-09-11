module Vendor::XCode::Objects

  class PBXFileReference < Vendor::XCode::Object

    reference :file_ref

    def name
      read_attribute :path
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
