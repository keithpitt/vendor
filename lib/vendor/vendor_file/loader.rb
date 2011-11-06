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

      def load(filename)
        @dsl.instance_eval(File.read(filename), filename)
      end

      def dependencies
        @dsl.libraries.map do |lib|
          all_dependencies lib
        end.flatten
      end

      def install(project)
        @dsl.libraries.each do |lib|
          lib.install project
        end
      end

      def dependency_graph
        @dsl.libraries.map { |lib| _dependencies(lib) }
      end

      private

        def _dependencies(library)
          [ library.name, library.version, library.dependencies.map { |l| _dependencies(l) } ]
        end

    end

  end
end
