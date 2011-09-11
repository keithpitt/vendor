module Vendor
  module VendorFile

    class DSL

      class UnknownLibraryType < StandardError; end

      attr_reader :sources
      attr_reader :libraries

      def initialize
        @sources = []
        @libraries = []
      end

      def source(source)
        @sources << Vendor::VendorFile::Source.new(source)
      end

      def lib(name, version = nil, options = nil)
        if options.nil? && version.kind_of?(Hash)
          options = version
          version = nil
        end

        klass = Vendor::VendorFile::Library::Remote

        if options
          if options.has_key?(:git)
            klass = Vendor::VendorFile::Library::Git
          elsif options.has_key?(:path)
            klass = Vendor::VendorFile::Library::Local
          end
        end

        options = { :version => version }.merge(options || {}) if version

        @libraries << klass.new({ :name => name, :targets => @with_targets }.merge(options || {}))
      end

      def target(*targets, &block)
        @with_targets = targets
        yield
        @with_targets = nil
      end

    end

  end
end
