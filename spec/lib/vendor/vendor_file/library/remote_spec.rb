require 'spec_helper'

describe Vendor::VendorFile::Library::Remote do

  let(:lib) { Vendor::VendorFile::Library::Remote.new(:name => "DKBenchmark", :version => "0.1") }

  context "#download" do

    before :each do
      Vendor.stub(:library_path).and_return Dir.mktmpdir("spec")
    end

    it "should find the correct version if one isn't set on the lib" do
      lib.version = nil

      lib.matched_version.should == "0.2"
    end

    it "should download the lib if its not cached locally" do
      Vendor::API.should_receive(:download).with(lib.name, lib.version).and_return(File.open(File.join(PACKAGED_VENDOR_PATH, "DKBenchmark-0.1.vendor")))

      lib.download
    end

    it "should not download the lib if it already exists" do
      File.should_receive(:exist?).with(lib.cache_path).and_return(true)
      Vendor::API.should_not_receive(:download).with(lib.name, lib.version)

      lib.download
    end

    it "should unzip the file" do
      lib.download

      File.exist?(File.join(lib.cache_path, "vendor.json"))
      File.exist?(File.join(lib.cache_path, "data/DKBenchmark.h"))
      File.exist?(File.join(lib.cache_path, "data/DKBenchmark.m"))
    end

  end

  context "#cache_path" do

    it "should contain the name of the vendor and the version" do
      lib.cache_path.should =~ /DKBenchmark\/0.1$/
    end

  end

  context "#matched_version" do

    it "should just return the version if there is no equality matche" do
      lib.version = "3.0.5"
      lib.matched_version.should == "3.0.5"
    end

    it "should just return the correct version if no version is passed" do
      lib.version = nil
      # The DKBenchmark FakeWeb call returns 0.2 as the latest release
      lib.matched_version.should == "0.2"
    end

    context "when finding the correct library" do

      before :each do
        lib.stub!('meta').and_return({ "versions" => [ [ "0.1"] , [ "0.1.1" ], [ "0.1.2.alpha" ], [ "0.2"] , [ "0.5" ], [ "0.6.1" ], [ "0.6.2" ], [ "0.6.8" ] ] })
      end

      it "should match <=" do
        lib.version = "<= 0.5"
        lib.matched_version.to_s.should == "0.6.8"
      end

      it "should match >=" do
        lib.version = ">= 0.2"
        lib.matched_version.to_s.should == "0.2"
      end

      it "should match >" do
        lib.version = "> 0.2"
        lib.matched_version.to_s.should == "0.1.1"
      end

      it "should match <" do
        lib.version = "< 0.2"
        lib.matched_version.to_s.should == "0.6.8"
      end

      it "should match ~>" do
        lib.version = "~> 0.6"
        lib.matched_version.to_s.should == "0.6.8"
      end

      it "should not return pre-releases" do
        lib.version = "~> 0.1"
        lib.matched_version.to_s.should == "0.1.1"
      end

      it "should return pre-releases if specified specifically" do
        lib.version = "~> 0.1.2.alpha"
        lib.matched_version.to_s.should == "0.1.2.alpha"
      end

    end

  end

  context "#==" do

    it "should return true if the libs match" do
      x = Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "1.0", :equality => "~>")
      y = Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "1.0", :equality => "~>")

      x.should == y
    end

    it "should return false if the libs don't match" do
      x = Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "1.0", :equality => "~>")
      y = Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "1.1", :equality => "~>")

      x.should_not == y
    end

  end

  context "#version=" do

    it "should have a version attribute" do
      lib.version = "3.0.5"

      lib.version.should == "3.0.5"
    end

    it "should handle versions with an equality matcher" do
      lib.version = "<= 3.0"
      lib.equality.should == "<="
      lib.version.should == "3.0"

      lib.version = ">= 3.1"
      lib.equality.should == ">="
      lib.version.should == "3.1"

      lib.version = "~> 3.2"
      lib.equality.should == "~>"
      lib.version.should == "3.2"
    end

    it "should clear the version and the equality if you pass nil" do
      lib.version = nil
      lib.equality.should be_nil
      lib.version.should be_nil
    end

    it "should exit if you pass something silly to it" do
      expect do
        Vendor.ui.should_receive(:error).with("Invalid version format '+ .5' for 'DKBenchmark'")
        lib.version = "+ .5"
      end.should raise_error(SystemExit)
    end

  end

end
