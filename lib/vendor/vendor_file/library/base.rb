module Vendor

  module VendorFile

    module Library

      class Base

        attr_accessor :parent

        attr_accessor :name
        attr_accessor :targets
        attr_accessor :require
        attr_accessor :version

        def initialize(attributes = {})
          @source_tree = :group
          @targets = [ :all ]
          attributes.each { |k, v| self.send("#{k}=", v) }
        end

        def targets=(value)
          if value
            @targets = [ *value ]
          end
        end

        alias :target= :targets=

        def cache_path
          File.join(Vendor.library_path, self.class.name.split('::').last.downcase, name)
        end

        def download
          # Do nothing by default, leave that up to the implementation
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

        def frameworks
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Find the frameworks
          frameworks = if manifest
            manifest['frameworks']
          elsif vendor_spec
            vendor_spec.frameworks
          end

          frameworks || []
        end

        def build_settings
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Find the build settings
          build_settings = if manifest
            manifest['build_settings']
          elsif vendor_spec
            vendor_spec.build_settings
          end

          build_settings || []
        end

        def files
          install_files_for_files_in 'files'
        end

        def resources
          install_files_for_files_in 'resources'
        end

        def version
          if @version
            @version
          elsif manifest
            manifest['version']
          elsif vendor_spec
            vendor_spec.version
          end
        end

        def per_file_flag
          # If the cache doesn't exist, download it
          download unless cache_exists?

          # Find the build settings
          per_file_flag = if manifest
            manifest['per_file_flag']
          elsif vendor_spec
            vendor_spec.per_file_flag
          end

          per_file_flag
        end


        def version_matches_any?(other_versions)
          # If we have an equality matcher, we need sort through
          # the versions, and try and find the best match
          wants = Vendor::Version.new(version)

          # Sort them from the latest versions first
          versions = other_versions.map{|v| Vendor::Version.create(v) }.sort.reverse

          # We don't want to include pre-releases if the wants version
          # isn't a pre-release itself. If we're after "2.5.alpha", then
          # we should be able to include that, however if we're asking for
          # "2.5", then pre-releases shouldn't be included.
          unless wants.prerelease?
            versions = versions.reject { |v| v.prerelease? }
          end

          versions.find { |has| wants == has }
        end

        def <=>(other)
          v = other.respond_to?(:version) ? other.version : other
          Vendor::Version.create(version) <=> Vendor::Version.create(v)
        end

        def ==(other)
          other.name == name && other.version == version
        end

        def display_name
          description
        end

        def description
          [ name, version ].compact.join(" ")
        end

        private

          def cache_exists?
            File.exist?(cache_path)
          end

          def vendor_spec
            # Cache the vendor spec
            return @vendor_spec if @vendor_spec

            # Try and find a vendorspec in the cached folder
            if cache_path
              file = Dir[File.join(cache_path, "*.vendorspec")].first

              if file && File.exist?(file)
                @vendor_spec = Vendor::Spec.load(file)
              else
                false
              end
            else
              false
            end
          end

          def manifest
            # Cache the manifest
            return @manifest if @manifest

            # Try and find a manifest (a built vendor file)
            if cache_path
              file = File.join(cache_path, "vendor.json")

              if File.exist?(file)
                @manifest = JSON.parse(File.read(file))
              else
                false
              end
            else
              false
            end
          end

          def install_files_for_files_in section
            # If the cache doesn't exist, download it
            download unless cache_exists?

            # Calculate the files we need to add. There are 3 different types
            # of installation:
            # 1) Installation from a manifest (a built lib)
            # 2) Loading the .vendorspec and seeing what files needed to be added
            # 3) Try to be smart and try and find files to install
            install_files = if manifest
                              Array(manifest[section]).map do |file|
                                File.join(cache_path, "data", file)
                              end
                            elsif vendor_spec
                              Array(vendor_spec.send(section)).map do |file|
                                File.join(cache_path, file)
                              end
                            else
                              location = [ cache_path, self.require, "**/*.*" ].compact
                              Dir[ File.join *location ]
                            end

          end

      end

    end

  end

end
