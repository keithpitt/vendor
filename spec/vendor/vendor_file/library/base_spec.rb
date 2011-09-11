require 'spec_helper'

describe Vendor::VendorFile::Library::Base do

  let(:lib) { Vendor::VendorFile::Library::Base.new }

  it "should have a name attribute" do
    lib.name = "lib"

    lib.name.should == "lib"
  end

  it "should have a target attribute" do
    lib.targets = "Specs"

    lib.targets.should == [ "Specs" ]
  end

end
