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

      def download
        @dsl.libraries.each do |lib|
          if lib.respond_to?(:sources=)
            lib.sources = @dsl.sources
          end
          lib.download
        end
      end

      def install(project)
        Vendor.ui.info "Installing into #{project.name}"

        @dsl.libraries.each do |lib|
          lib.install project
        end
      end

    end

  end
end
