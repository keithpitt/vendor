module Vendor
  module VendorFile
    module Library

      class Git < Base

        attr_accessor :uri
        attr_accessor :tag

        alias :branch= :tag=
        alias :ref= :tag=

        def initialize(attributes = {})
          super({ :tag => "master" }.merge(attributes))
        end

      end

    end
  end
end
