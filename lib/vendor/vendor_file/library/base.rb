module Vendor
  module VendorFile
    module Library

      class Base

        attr_accessor :name
        attr_accessor :targets

        def initialize(attributes = {})
          attributes.each { |k, v| self.send("#{k}=", v) }
        end

        def targets=(value)
          @targets = [ *value ]
        end

        alias :target= :targets=

      end

    end
  end
end
