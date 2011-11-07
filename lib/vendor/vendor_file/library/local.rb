module Vendor
  module VendorFile
    module Library

      class Local < Base

        attr_accessor :path

        def initialize(*args)
          super(*args)
          @source_tree = :absolute
        end

        def cache_path
          File.expand_path(path) if path
        end

      end

    end
  end
end
