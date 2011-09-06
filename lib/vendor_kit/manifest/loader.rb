module VendorKit
  module Manifest

    class Loader

      attr_reader :dsl

      def initialize
        @dsl = VendorKit::Manifest::DSL.new
      end

      def manifest(&block)
        @dsl.instance_eval &block
      end

      def load(filename)
        self.instance_eval(File.read(filename), filename)
      end

    end

  end
end
