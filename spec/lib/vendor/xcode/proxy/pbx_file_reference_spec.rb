require 'spec_helper'

describe Vendor::XCode::Proxy::PBXFileReference do

  describe "#file_type_from_extension" do

    { ".h"         => "sourcecode.c.h",
      ".m"         => "sourcecode.c.objc",
      ".c"         => "sourcecode.c.c",
      ".bundle"    => "wrapper.plug-in",
      ".framework" => "wrapper.framework",
      ".a"         => "archive.ar",
      ".strings"   => "text.plist.strings",
      ".plist"     => "text.plist.xml",
      ".png"       => "image.png",
      ".jpg"       => "image.jpg" }.each do |key, value|

      it "when passing #{key} should return #{value}" do
        Vendor::XCode::Proxy::PBXFileReference.file_type_from_extension(key).should == value
      end

    end

  end

end
