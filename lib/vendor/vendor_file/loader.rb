module Vendor
  module VendorFile

    class Loader

      attr_reader :dsl

      def initialize
        @dsl = Vendor::VendorFile::DSL.new
      end

      def load(filename)
        @dsl.instance_eval(File.read(filename), filename)
      end

    end

  end
end
