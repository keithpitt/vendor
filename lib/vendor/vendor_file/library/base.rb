module Vendor

  module VendorFile

    module Library

      class Base

        attr_accessor :name
        attr_accessor :targets
        attr_accessor :require

        def initialize(attributes = {})
          @source_tree = :group
          attributes.each { |k, v| self.send("#{k}=", v) }
        end

        def targets=(value)
          @targets = [ *value ]
        end

        alias :target= :targets=

        def cache_path
          @cache_path ||= File.join(Vendor.library_path, self.class.name.split('::').last.downcase, name)
        end

        def download
          # Do nothing by default, leave that up to the implementation
        end

        def install(project)
          destination = "Vendor/#{name}"

          Vendor.ui.debug "Installing #{name} into #{project} (location = #{destination}, source_tree = #{@source_tree})"

          # Remove the group, and recreate
          project.remove_group destination

          # Install the files back into the project
          files.each do |file|
            Vendor.ui.debug "Copying file #{file} to #{destination}"

            project.add_file :targets => targets, :path => destination,
                             :file => file, :source_tree => @source_tree
          end
        end

        def files
          unless File.exist?(cache_path)
            Vendor.ui.error "Could not find libray `#{name}` at path `#{cache_path}`"
            return []
          end

          # Try and find a vendorspec in the cached folder
          vendor_spec = Dir[File.join(cache_path, "*.vendorspec")].first

          # Try and find a manifest (a built vendor file)
          manifest = File.join(cache_path, "vendor.json")

          # Calculate the files we need to add. There are 3 different types
          # of installation:
          # 1) Installation from a manifest (a built lib)
          # 2) Loading the .vendorspec and seeing what files needed to be added
          # 3) Try to be smart and try and find files to install
          install_files = if manifest && File.exist?(manifest)

            json = JSON.parse(File.read(manifest))
            json['files'].map { |file| File.join(cache_path, "data", file) }

          elsif vendor_spec && File.exist?(vendor_spec)

            spec = Vendor::Spec.load(vendor_spec)
            spec.files.map { |file| File.join(cache_path, file) }

          else

            location = [ cache_path, self.require, "**/*.*" ].compact
            Dir[ File.join *location ]

          end

          # Remove files that are within folders with a ".", such as ".bundle"
          # and ".frameworks"
          install_files.reject { |file| file =~ /\/?[^\/]+\.[^\/]+\// }
        end

      end

    end

  end

end
