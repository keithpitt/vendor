module Vendor
  module VendorFile

    class DependencyGraph

      attr_accessor :libraries
      attr_reader :libraries_to_install

      def initialize(libs = nil)
        self.libraries = libs
      end

      def libraries=(value)
        if value
          # We want our own array, not a pointer to the old one, but we
          # can keep the contents, thats fine.
          @libraries = [ *value ]
        else
          @libraries = nil
        end
      end

      def dependency_graph
        map = {}
        _touched = {}
        graph = []
        @libraries.each do |lib|
          if (x = _map(lib, map, _touched))
            graph << x
          end
        end

        return graph, map
      end

      def version_conflicts?
        graph, map = dependency_graph

        # The version conflict detector is pretty stupid, pretty much if
        # two libraries are trying to include a lib of different
        # versions:
        # a requires b v1.0
        # c requires b v1.1
        # Then things will blow up.

        @libraries_to_install = []

        map.keys.sort.each do |name|

          libs = map[name]

          # Only populate the "targets" element if there is a specific
          # target to add to.
          found_targets = libs.find_all { |l| l.targets if l.targets }.map &:targets
          targets = found_targets.empty? ? nil : found_targets.flatten.compact.uniq

          version_to_install = libs.first

          # Check for conflicts and try to resolve
          if libs.length > 1

            # Sort the versions, starting with the latest version first
            versions = libs.sort.reverse

            # This code is a little yucky, but what it does, is it tries
            # to find the best version match for every other version in
            # the loop. So, lets say we have versions => 0.1 and ~> 0.1,
            # and we have an array of [ "0.1", "0.1.1" ], try and find
            # the higest versiont that each likes. Once we know that, we
            # uniqify the results. If we have more than 1, that means we
            # have a conflict.
            vvs = versions.map(&:version)
            matched_versions = libs.map do |l|
              l.version_matches_any?(vvs)
            end.inject([]) do |uniqs, obj|
              if uniqs.all? { |e| e != obj }
                uniqs << obj
              end
              uniqs
            end

            if matched_versions.length > 1
              version_to_install = nil
            else
              # Find the version we've recomended and install that one.
              y = matched_versions.first
              version_to_install = versions.find do |x|
                x.version == y.to_s
              end
            end

          end

          # Are there multiple versions to install?
          unless version_to_install
            Vendor.ui.error "Multiple versions detected for #{name} (#{versions.map(&:version).join(', ')})"

            # A semi-meaningfull error
            libs.each do |v|
              if v.parent
                Vendor.ui.error "  #{v.description} is required by #{v.parent.description}"
              else
                Vendor.ui.error "  #{v.description} is required in the Vendorfile"
              end
            end

            exit
          else
            @libraries_to_install << [ version_to_install, targets ]
          end
        end

        false
      end

      private

        def _map(library, map, _touched)
          unless _touched[library.description]
            # Add the library to the map
            map[library.name] ||= []
            map[library.name] << library

            # So we don't traverse this object again
            _touched[library.description] = true

            # Return the graph
            [ library.description, library.dependencies.map { |l| _map(l, map, _touched) }.compact ]
          end
        end

    end

  end
end
