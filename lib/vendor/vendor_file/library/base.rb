module Vendor

  module VendorFile

    module Library

      class Base

        attr_accessor :parent

        attr_accessor :name
        attr_accessor :targets
        attr_accessor :require

        def initialize(attributes = {})
          @source_tree = :group
          @targets = [ :all ]
          attributes.each { |k, v| self.send("#{k}=", v) }
        end

        def targets=(value)
          @targets = [ *value ]
        end

        alias :target= :targets=

        def cache_path
          File.join(Vendor.library_path, self.class.name.split('::').last.downcase, name)
        end

        def download
          # Do nothing by default, leave that up to the implementation
        end

        def install(project, options = {})
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Combine the local targets, with those targets specified in the options. Also
          # for sanity reasons, flatten and uniqify them.
          install_targets = [ @targets, options[:targets] ].compact.flatten.uniq

          # The destination in the XCode project
          destination = "Vendor/#{name}"
          Vendor.ui.debug "Installing #{name} into #{project} (location = #{destination}, source_tree = #{@source_tree}, targets = #{install_targets.inspect})"

          # Remove the group, and recreate
          project.remove_group destination

          # Install the files back into the project
          files.each do |file|
            project.add_file :targets => install_targets, :path => destination,
                             :file => file, :source_tree => @source_tree
          end
        end

        def dependencies
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Find the dependencies
          dependencies = if manifest
            manifest['dependencies']
          elsif vendor_spec
            vendor_spec.dependencies
          end

          # Create remote objects to represent the dependencies
          (dependencies || []).map do |d|
            Vendor::VendorFile::Library::Remote.new(:name => d[0], :version => d[1], :parent => self, :targets => @targets)
          end
        end

        def files
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Calculate the files we need to add. There are 3 different types
          # of installation:
          # 1) Installation from a manifest (a built lib)
          # 2) Loading the .vendorspec and seeing what files needed to be added
          # 3) Try to be smart and try and find files to install
          install_files = if manifest
                            manifest['files'].map do |file|
                              File.join(cache_path, "data", file)
                            end
                          elsif vendor_spec
                            vendor_spec.files.map do |file|
                              File.join(cache_path, file)
                            end
                          else
                            location = [ cache_path, self.require, "**/*.*" ].compact
                            Dir[ File.join *location ]
                          end

          # Remove files that are within folders with a ".", such as ".bundle"
          # and ".frameworks"
          install_files.reject do |file|
            file.gsub(cache_path, "") =~ /\/?[^\/]+\.[^\/]+\//
          end
        end

        private

          def cache_exists?
            File.exist?(cache_path)
          end

          def vendor_spec
            # Cache the vendor spec
            return @vendor_spec if @vendor_spec

            # Try and find a vendorspec in the cached folder
            file = Dir[File.join(cache_path, "*.vendorspec")].first

            if file && File.exist?(file)
              @vendor_spec = Vendor::Spec.load(file)
            else
              false
            end
          end

          def manifest
            # Cache the manifest
            return @manifest if @manifest

            # Try and find a manifest (a built vendor file)
            file = File.join(cache_path, "vendor.json")

            if File.exist?(file)
              @manifest = JSON.parse(File.read(file))
            else
              false
            end
          end

      end

    end

  end

end
