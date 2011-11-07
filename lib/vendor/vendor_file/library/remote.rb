module Vendor
  module VendorFile
    module Library

      class Remote < Base

        require 'zip/zip'

        attr_accessor :version
        attr_accessor :equality
        attr_accessor :sources

        def version=(value)
          # Matches (some equality matcher, followed by some spaces, then a version)
          if value
            if value.match(/^(\<\=|\>\=|\~\>|\>|\<)?\s*([a-zA-Z0-9\.]+)$/)
              @equality = $1
              @version = $2
            else
              Vendor.ui.error "Invalid version format '#{value}' for '#{name}'"
              exit 1
            end
          else
            @equality = nil
            @version = nil
          end
          value
        end

        def matched_version
          # If we just have a version, and no equality matcher
          if version && !equality
            return version
          end

          # If we don't have a version, get the latest version
          # from the remote sources
          unless version
            return meta['release']
          end

          # Try and find a version that matches the lib
          found = version_matches_any?(meta['versions'].map { |v| v[0] })

          # Did we actually find something?
          unless found
            Vendor.ui.error "Could not find a valid version '#{equality} #{version}' in '#{versions}'"
            exit 1
          else
            found
          end
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

          # If this a spermy search, we have a slightly different search mechanism. We use the
          # version segemets to determine if the version is valid. For example, lets say we're
          # testing to see if "0.1" is a spermy match to "0.1.5.2", we start by getting the
          # two segments for each:
          #
          # [ 0, 1 ]
          # [ 0, 1, 5, 2 ]
          #
          # We chop the second set of segments to be the same lenth as the first one:
          #
          # [ 0, 1, 5, 2 ].slice(0, 2) #=. [ 0, 1 ]
          #
          # No we just test to see if they are the same! I think this works...
          if equality == "~>"
            segments = wants.segments
            versions.find do |has|
              segments == has.segments.slice(0, segments.length)
            end
          elsif equality
            versions.find do |has|
              wants.send(:"#{equality}", has)
            end
          else
            versions.find do |has|
              wants == has
            end
          end
        end

        def download
          # If we haven't already downloaded the vendor
          unless File.exist?(cache_path)
            Vendor.ui.info %{Downloading #{name}}

            # Download it
            file = Vendor::API.download(name, matched_version)

            # Unzip the download
            unzip_file file.path, cache_path
          end
        end

        def cache_path
          File.join(Vendor.library_path, "remote", name, matched_version.to_s)
        end

        def ==(other)
          other.name == @name && other.version == @version && other.equality == @equality
        end

        def <=>(other)
          v = other.respond_to?(:version) ? other.version : other
          Vendor::Version.create(@version) <=> Vendor::Version.create(v)
        end

        def description
          [ @name, @equality, @version ].compact.join(" ")
        end

        private

          def meta
            @meta ||= Vendor::API.meta(name)
          end

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
