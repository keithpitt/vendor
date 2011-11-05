require 'spec_helper'

describe Vendor::VendorFile::Library::Remote do

  let(:lib) { Vendor::VendorFile::Library::Remote.new(:name => "DKBenchmark", :version => "0.1") }

  it "should have a version attribute" do
    lib.version = "3.0.5"

    lib.version.should == "3.0.5"
  end

  context "#download" do

    before :each do
      Vendor.stub(:library_path).and_return Dir.mktmpdir("spec")
    end

    it "should find the correct version if one isn't set on the lib" do
      lib.version = nil
      lib.download

      lib.version.should == "0.2"
    end

    it "should download the lib if its not cached locally" do
      Dir.should_receive(:exist?).with(lib.cache_path).and_return(false)
      Vendor::API.should_receive(:download).with(lib.name, lib.version).and_return(File.open(File.join(PACKAGED_VENDOR_PATH, "DKBenchmark-0.1.vendor")))

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

end
