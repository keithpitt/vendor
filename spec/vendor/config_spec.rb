require 'spec_helper'

describe Vendor::Config do

  context "#directory" do

    it "should return the development directory" do
      Vendor::Config.directory.should == File.expand_path(File.join(__FILE__, "..", "..", "..", "tmp", "config"))
    end

  end

  context "#directory=" do

    it "should allow you to set a new directory" do
      old_directory = Vendor::Config.directory

      Vendor::Config.directory = "something"
      Vendor::Config.directory.should == "something"

      Vendor::Config.directory = old_directory
    end

  end

  context "#set" do

    it "should create a file if one doesn't exist" do
      Vendor::Config.set "some.config", "a value"

      File.exist?(File.join(Vendor::Config.directory, "config")).should be_true
    end

    it "should allow you to set configs" do
      Vendor::Config.set "config", "a value"

      Vendor::Config.get("config").should == "a value"
    end

    it "should allow you to set configs at multiple levels" do
      Vendor::Config.set "config.at.some.crazy.level", "a value"

      Vendor::Config.get("config.at.some.crazy.level").should == "a value"
    end

    it "should allow you to set symbols" do
      Vendor::Config.set :"config.at.some.crazy.level", "a value"

      Vendor::Config.get("config.at.some.crazy.level").should == "a value"
    end

  end

  context "#get" do

    it "should return nil if the config doesn't exist" do
      Vendor::Config.get("this.dont.exist").should be_nil
    end

  end

end
