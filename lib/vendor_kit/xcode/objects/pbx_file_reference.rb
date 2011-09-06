module VendorKit::XCode::Objects

  class PBXFileReference < VendorKit::XCode::Object

    reference :file_ref

    def name
      read_attribute :path
    end

  end

end
