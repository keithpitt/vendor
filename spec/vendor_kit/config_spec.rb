require 'spec_helper'

describe VendorKit::Config do

  context "#directory" do

    it "should return the development directory" do
      VendorKit::Config.directory.should == File.expand_path(File.join(__FILE__, "..", "..", "..", "tmp", "config"))
    end

  end

  context "#directory=" do

    it "should allow you to set a new directory" do
      old_directory = VendorKit::Config.directory

      VendorKit::Config.directory = "something"
      VendorKit::Config.directory.should == "something"

      VendorKit::Config.directory = old_directory
    end

  end

  context "#set" do

    it "should create a file if one doesn't exist" do
      VendorKit::Config.set "some.config", "a value"

      File.exist?(File.join(VendorKit::Config.directory, "config")).should be_true
    end

    it "should allow you to set configs" do
      VendorKit::Config.set "config", "a value"

      VendorKit::Config.get("config").should == "a value"
    end

    it "should allow you to set configs at multiple levels" do
      VendorKit::Config.set "config.at.some.crazy.level", "a value"

      VendorKit::Config.get("config.at.some.crazy.level").should == "a value"
    end

    it "should allow you to set symbols" do
      VendorKit::Config.set :"config.at.some.crazy.level", "a value"

      VendorKit::Config.get("config.at.some.crazy.level").should == "a value"
    end

  end

  context "#get" do

    it "should return nil if the config doesn't exist" do
      VendorKit::Config.get("this.dont.exist").should be_nil
    end

  end

end
