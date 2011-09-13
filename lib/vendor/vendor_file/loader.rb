module Vendor
  module VendorFile

    class Loader

      require 'fileutils'

      attr_reader :dsl

      def initialize
        @dsl = Vendor::VendorFile::DSL.new
      end

      def load(filename)
        @dsl.instance_eval(File.read(filename), filename)
      end

      def download(path)
        FileUtils.mkdir_p(path)

        @dsl.libraries.each do |lib|
          if lib.respond_to?(:sources=)
            lib.sources = @dsl.sources
          end
          lib.download(path)
        end
      end

      def install(project)
      end

    end

  end
end
