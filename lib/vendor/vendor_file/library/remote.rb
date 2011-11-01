module Vendor
  module VendorFile
    module Library

      class Remote < Base

        attr_accessor :version
        attr_accessor :sources

        def download
          Vendor.ui.info "download #{name} version #{version} from #{sources} to #{cache_path}"
        end

      end

    end
  end
end
