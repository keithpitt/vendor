module Vendor::XCode::Proxy

  class PBXAggregateTarget < Vendor::XCode::Proxy::Base

    reference :build_phases
    reference :dependencies
    reference :build_configuration_list

  end

end
