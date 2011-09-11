module Vendor::XCode::Objects

  class PBXNativeTarget < Vendor::XCode::Object

    reference :build_phases
    reference :product_reference
    reference :build_configuration_list

  end

end
