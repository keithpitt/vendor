module Vendor::XCode::Proxy

  class PBXGroup < Vendor::XCode::Proxy::Base

    reference :children

    def name
      @attributes['name'] || @attributes['path']
    end

  end

end
