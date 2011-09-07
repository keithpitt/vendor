require 'spec_helper'

describe VendorKit::Manifest::Builder do

  context "#initialize" do

    context "with a valid vendor spec" do

      let (:builder) { VendorKit::Manifest::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.manifest")) }

      it "should load in the vendor spec" do
        builder.manifest[:name].should == "DKBenchmark"
      end

      it "should load the name of the vendor" do
        builder.name.should == "DKBenchmark"
      end

      it "should the version of the vendor" do
        builder.version.should == "0.1"
      end

      it "should create a filename for the vendor" do
        builder.filename.should == "DKBenchmark-0.1.vendor"
      end

    end

    context "with an invalid vendor spec" do

      let (:builder) { VendorKit::Manifest::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmarkUnsafe", "DKBenchmark.manifest")) }

      it "should load in the vendor spec" do
        builder.manifest[:name].should == "DKBen!/asdf535chmark"
      end

      it "should load the name of the vendor" do
        builder.name.should == "DKBenasdf535chmark"
      end

      it "should the version of the vendor" do
        builder.version.should == "0.1asdf52fs"
      end

      it "should create a filename for the vendor" do
        builder.filename.should == "DKBenasdf535chmark-0.1asdf52fs.vendor"
      end

    end

  end

  context "#build" do

    let (:builder) { VendorKit::Manifest::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.manifest")) }

    before :all do
      builder.build
    end

    it "should create the .vendor file" do
      File.exist?(builder.filename).should be_true
    end

    it "should be a zip file" do
      mimetype = `file -Ib #{builder.filename}`.chomp

      mimetype.should == "application/zip; charset=binary"
    end

    it "should contain a vendor.json file" do
      Zip::ZipFile.open(builder.filename) do |zipfile|
        zipfile.file.read("vendor.json").should == builder.manifest.to_json
      end
    end

    it "should contain the files contained in the vendor spec" do
      Zip::ZipFile.open(builder.filename) do |zipfile|
        zipfile.file.read("data/DKBenchmark.h") =~ /DKBenchmark\.h/
        zipfile.file.read("data/DKBenchmark.m") =~ /DKBenchmark\.m/
      end
    end

  end

end
