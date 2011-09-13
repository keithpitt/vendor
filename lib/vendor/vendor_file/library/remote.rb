module Vendor
  module VendorFile
    module Library

      class Remote < Base

        attr_accessor :version
        attr_accessor :sources

        def download(path)
          puts "download #{name} version #{version} from #{sources} to #{path}"
        end

      end

    end
  end
end
