module VendorKit
  module Manifest

    class DSL

      attr_reader :manifest

      def initialize
        @manifest = Hash.new
      end

      def method_missing(name, *args)
        if name.to_s.match(/\=$/) || args.length > 0
          without_equals = name.to_s.gsub(/=$/, '')

          @manifest[without_equals.to_sym] = args.length == 1 ? args.first : args
        else
          @manifest[name.to_sym]
        end
      end

      def validate!
        [ :name, :version, :email, :files ].each do |key|
          value = @manifest[key]

          if value.respond_to?(:empty?) ? value.empty? : !value
            raise StandardError.new("Vendor manifest is missing the `#{key}` option")
          end
        end
      end

      def to_json
        manifest.to_json
      end

    end

  end
end
