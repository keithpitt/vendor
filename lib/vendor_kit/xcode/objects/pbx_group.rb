module VendorKit::XCode::Objects

  class PBXGroup < VendorKit::XCode::Object

    reference :children

    def name
      @attributes['name'] || @attributes['path']
    end

  end

end
