module VendorKit::XCode::Objects

  class PBXNativeTarget < VendorKit::XCode::Object

    reference :build_phases
    reference :product_reference

  end

end
