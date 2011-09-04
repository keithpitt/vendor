module VendorKit::XCode::Objects

  class PBXProject < VendorKit::XCode::Object

    reference :build_configuration_list
    reference :product_ref_group
    reference :main_group
    reference :targets

  end

end
