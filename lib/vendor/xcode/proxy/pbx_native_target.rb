module Vendor::XCode::Proxy

  class PBXNativeTarget < Vendor::XCode::Proxy::Base

    reference :build_phases
    reference :product_reference
    reference :build_configuration_list

  end

end
