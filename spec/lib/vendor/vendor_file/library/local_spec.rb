require 'spec_helper'

describe Vendor::VendorFile::Library::Local do

  let(:lib) { Vendor::VendorFile::Library::Local.new }

  it "should have a path attribute" do
    lib.path = "~/Development/something"

    lib.path.should == "~/Development/something"
  end

end
