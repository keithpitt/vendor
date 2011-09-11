require 'spec_helper'

describe Vendor::VendorFile::Library::Remote do

  let(:lib) { Vendor::VendorFile::Library::Remote.new }

  it "should have a version attribute" do
    lib.version = "3.0.5"

    lib.version.should == "3.0.5"
  end

end
