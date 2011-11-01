require 'spec_helper'

describe Vendor::VendorFile::Library::Local do

  let(:lib) { Vendor::VendorFile::Library::Local.new(:path => "~/Development/something") }

  it "should have a path attribute" do
    lib.path.should == "~/Development/something"
  end

  describe "#cache_path" do

    it "should return the path expanded" do
      lib.cache_path.should == File.expand_path("~/Development/something")
    end

  end

end
