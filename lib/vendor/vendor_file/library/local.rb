module Vendor
  module VendorFile
    module Library

      class Local < Base

        attr_accessor :path

        def cache_path
          File.expand_path(path)
        end

      end

    end
  end
end
