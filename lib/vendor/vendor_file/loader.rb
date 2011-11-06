module Vendor
  module VendorFile

    class Loader

      require 'fileutils'

      attr_reader :dsl
      attr_reader :libraries

      def initialize
        @dsl = Vendor::VendorFile::DSL.new
        @libraries = []
      end

      def libraries=(value)
        @graph = Vendor::VendorFile::DependencyGraph.new(value)
        @libraries = value
      end

      def load(filename)
        @dsl.instance_eval(File.read(filename), filename)
        self.libraries = @dsl.libraries
      end

      def install(project)
        unless @graph.version_conflicts?
          @graph.libraries_to_install.each do |lib|
            lib[0].install project, :targets => lib[1]
          end
        end
      end

    end

  end
end
