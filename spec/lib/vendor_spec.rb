require 'spec_helper'

describe Vendor do

  context "#version" do

    it "should return the version of vendor" do
      Vendor.version.should == File.read(File.join(Vendor.root, "..", "VERSION")).chomp
      Vendor.version.should_not be_nil
      Vendor.version.should_not be_empty
    end

  end

end
