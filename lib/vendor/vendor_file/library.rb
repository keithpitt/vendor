module Vendor

  module VendorFile

    module Library

      autoload :Base,   "vendor/vendor_file/library/base"
      autoload :Git,    "vendor/vendor_file/library/git"
      autoload :Remote, "vendor/vendor_file/library/remote"
      autoload :Local,  "vendor/vendor_file/library/local"

    end

  end

end
