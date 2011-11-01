module Vendor

  module VendorFile

    module Library

      class Base

        attr_accessor :name
        attr_accessor :targets

        def initialize(attributes = {})
          attributes.each { |k, v| self.send("#{k}=", v) }
        end

        def targets=(value)
          @targets = [ *value ]
        end

        def download
          # Do nothing by default, leave that up to the implementation
        end

        def install(project)
          Vendor.ui.debug "Installing #{name} into #{project}"

          destination = "Vendor/#{name}"

          # Remove the group, and recreate
          project.remove_group destination

          # Install the files back into the project
          install_files.each do |file|
            Vendor.ui.debug "Copying file #{file} to #{destination}"

            project.add_file :targets => targets, :path => destination, :file => file
          end
        end

        alias :target= :targets=

        private

          def install_files
            if File.exist?(cache_path)
              vendorspec = Dir[File.join(cache_path, "*.vendorspec")].first
              manifest = File.join(cache_path, "vendor.json")

              if manifest && File.exist?(manifest)
                puts "Pulling from #{manifest}"
              elsif vendorspec && File.exist?(vendorspec)
                puts "Pulling from #{vendorspec}"
              else
                Dir[File.join(cache_path, "**/*.[hm]")]
              end
            end
          end

          def cache_path
            @cache_path ||= File.join(Vendor.library_path, self.class.name.split('::').last.downcase, name)
          end

      end

    end

  end

end
