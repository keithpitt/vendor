module Vendor
  module VendorFile
    module Library

      class Remote < Base

        require 'zip/zip'

        attr_accessor :version
        attr_accessor :sources

        def download
          # If no version is supplied, get the latest one from the
          # source
          unless version
            @version = Vendor::API.meta(name)['release']
          end

          # If we haven't already downloaded the vendor
          unless File.exist?(cache_path)
            # Download it
            file = Vendor::API.download(name, version)

            # Unzip the download
            unzip_file file.path, cache_path
          end
        end

        def cache_path
          File.join(Vendor.library_path, "remote", name, version)
        end

        private

          def unzip_file (file, destination)
            Zip::ZipFile.open(file) { |zip_file|
              zip_file.each { |f|
                f_path = File.join(destination, f.name)
                FileUtils.mkdir_p(File.dirname(f_path))
                zip_file.extract(f, f_path) unless File.exist?(f_path)
              }
            }
          end

      end

    end
  end
end
