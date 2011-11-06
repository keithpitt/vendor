module Vendor::XCode::Proxy

  class PBXFrameworksBuildPhase < Vendor::XCode::Proxy::Base

    reference :files

    private

      def after_initialize
        files.each { |child| child.parent = self }
      end

  end

end
