module Vendor::XCode::Proxy

  class PBXShellScriptBuildPhase < Vendor::XCode::Proxy::Base

    reference :files

    private

      def after_initialize
        files.each { |child| child.parent = self }
      end

  end

end
