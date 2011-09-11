module Vendor
  module VendorSpec

    class DSL

      attr_reader :vendor_spec

      def initialize
        @vendor_spec = Hash.new
      end

      def method_missing(name, *args)
        if name.to_s.match(/\=$/) || args.length > 0
          without_equals = name.to_s.gsub(/=$/, '')

          @vendor_spec[without_equals.to_sym] = args.length == 1 ? args.first : args
        else
          @vendor_spec[name.to_sym]
        end
      end

      def validate!
        [ :name, :version, :email, :files ].each do |key|
          value = @vendor_spec[key]

          if value.respond_to?(:empty?) ? value.empty? : !value
            raise StandardError.new("Specification is missing the `#{key}` option")
          end
        end
      end

      def to_json
        vendor_spec.to_json
      end

    end

  end
end
