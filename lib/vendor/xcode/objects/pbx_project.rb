module Vendor::XCode::Objects

  class PBXProject < Vendor::XCode::Object

    reference :build_configuration_list
    reference :product_ref_group
    reference :main_group
    reference :targets

  end

end
