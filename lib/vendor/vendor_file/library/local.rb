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
          expanded_path if path
        end

        def display_name
          [ name, "(#{expanded_path})" ].join(' ')
        end

        private

          def expanded_path
            File.expand_path(path)
          end

      end

    end
  end
end
