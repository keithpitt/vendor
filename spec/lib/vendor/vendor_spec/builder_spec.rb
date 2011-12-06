require 'spec_helper'

describe Vendor::VendorSpec::Builder do

  context "#initialize" do

    context "with a valid vendor spec" do

      let (:builder) { Vendor::VendorSpec::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.vendorspec")) }

      it "should load in the vendor spec" do
        builder.vendor_spec.name.should == "DKBenchmark"
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

      let (:builder) { Vendor::VendorSpec::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmarkUnsafe", "DKBenchmark.vendorspec")) }

      it "should load in the vendor spec" do
        builder.vendor_spec.name.should == "DKBen!/asdf535chmark"
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

    context "with a valid vendor spec" do

      let (:builder) { Vendor::VendorSpec::Builder.new(File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.vendorspec")) }

      before :all do
        builder.build
      end

      it "should create the .vendor file" do
        File.exist?(builder.filename).should be_true
      end

      it "should be a zip file" do
        mimetype = `file #{builder.filename} --mime-type`.chomp

        mimetype.should =~ /application\/zip/
      end

      it "should contain a vendor.json file" do
        Zip::ZipFile.open(builder.filename) do |zipfile|
          zipfile.file.read("vendor.json").should == builder.vendor_spec.to_json
        end
      end

      it "should contain the files contained in the vendor spec" do
        Zip::ZipFile.open(builder.filename) do |zipfile|
          zipfile.file.read("data/DKBenchmark.h") =~ /DKBenchmark\.h/
          zipfile.file.read("data/DKBenchmark.m") =~ /DKBenchmark\.m/
        end
      end

    end

    context "with no files" do

      let (:builder) { Vendor::VendorSpec::Builder.new(File.join(VENDOR_RESOURCE_PATH, "EmptyVendor", "EmptyVendor.vendorspec")) }

      it "should not allow you to build" do
        expect do
          builder.build
        end.should raise_error(Vendor::VendorSpec::Builder::NoFilesError, "No files found for packaging")
      end

    end

  end

end
