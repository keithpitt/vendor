module Vendor
  module VendorSpec

    class Loader

      attr_reader :dsl

      def initialize
        @dsl = Vendor::VendorSpec::DSL.new
      end

      def vendor(&block)
        @dsl.instance_eval &block
      end

      def load(filename)
        @dsl.instance_eval(File.read(filename), filename)
      end

    end

  end
end
