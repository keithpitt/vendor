module Vendor

  module VendorFile

    module Library

      class Base

        attr_accessor :name
        attr_accessor :targets
        attr_accessor :require

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
          files.each do |file|
            Vendor.ui.debug "Copying file #{file} to #{destination}"

            project.add_file :targets => targets, :path => destination, :file => file
          end
        end

        def files
          return [] unless File.exist?(cache_path)

          # Try and find a vendorspec in the cached folder
          vendorspec = Dir[File.join(cache_path, "*.vendorspec")].first

          # Try and find a manifest (a built vendor file)
          manifest = File.join(cache_path, "vendor.json")

          # Calculate the files we need to add
          install_files = if manifest && File.exist?(manifest)
            puts "Pulling from #{manifest}"
          elsif vendorspec && File.exist?(vendorspec)
            puts "Pulling from #{vendorspec}"
          else
            parts = [cache_path, self.require, "**/*.*"].compact
            Dir[File.join(*parts)]
          end

          # Remove files that are within folders with a ".", such as ".bundle"
          # and ".frameworks"
          install_files.reject { |file| file =~ /\/?[^\/]+\.[^\/]+\// }
        end

        alias :target= :targets=

        private

          def cache_path
            @cache_path ||= File.join(Vendor.library_path, self.class.name.split('::').last.downcase, name)
          end

      end

    end

  end

end
