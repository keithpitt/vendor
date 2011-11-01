require 'spec_helper'

describe Vendor::VendorFile::Library::Git do

  it "should default the tag to 'master'" do
    lib = Vendor::VendorFile::Library::Git.new

    lib.tag.should == "master"
  end

  it "setting a branch should set the tag" do
    lib = Vendor::VendorFile::Library::Git.new(:branch => "develop")

    lib.tag.should == "develop"
  end

  it "setting a ref should set the tag" do
    lib = Vendor::VendorFile::Library::Git.new(:ref => "3g34g34")

    lib.tag.should == "3g34g34"
  end

end
