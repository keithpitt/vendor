module Vendor::XCode::Proxy

  class PBXProject < Vendor::XCode::Proxy::Base

    reference :build_configuration_list
    reference :product_ref_group
    reference :main_group
    reference :targets

  end

end
