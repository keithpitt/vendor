require 'spec_helper'

describe Vendor::VendorFile::Source do

  it "should allow you to set a uri via a string" do
    source = Vendor::VendorFile::Source.new("http://google.com")

    source.uri.should == "http://google.com"
  end

  it "should allow you to set a uri via a symbol" do
    source = Vendor::VendorFile::Source.new(:vendorforge)

    source.uri.should == "http://vendorkit.com"
  end

end
