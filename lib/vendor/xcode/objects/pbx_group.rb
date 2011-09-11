module Vendor::XCode::Objects

  class PBXGroup < Vendor::XCode::Object

    reference :children

    def name
      @attributes['name'] || @attributes['path']
    end

  end

end
