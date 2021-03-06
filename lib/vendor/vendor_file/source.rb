module Vendor
  module VendorFile

    class Source

      MAPPING = { :vendorforge => "http://vendorkit.com", :vendorkit => "http://vendorkit.com" }

      attr_accessor :uri

      def initialize(uri)
        if uri.kind_of?(Symbol)
          self.uri = MAPPING[uri]
        else
          self.uri = uri
        end
      end

    end

  end
end
