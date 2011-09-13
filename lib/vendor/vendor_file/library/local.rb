module Vendor
  module VendorFile
    module Library

      class Local < Base

        attr_accessor :path

        def download(path)
          puts "nothing to download, just reference #{path}"
        end

      end

    end
  end
end
