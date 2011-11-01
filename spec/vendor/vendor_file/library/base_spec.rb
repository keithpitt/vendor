require 'spec_helper'

describe Vendor::VendorFile::Library::Base do

  let(:lib) { Vendor::VendorFile::Library::Base.new }

  let(:temp_path) { TempProject.create(File.join(PROJECT_RESOURCE_PATH, "UtilityApplication")) }
  let(:project) { Vendor::XCode::Project.new(File.join(temp_path, "UtilityApplication.xcodeproj")) }

  it "should have a name attribute" do
    lib.name = "lib"

    lib.name.should == "lib"
  end

  it "should have a target attribute" do
    lib.targets = "Specs"

    lib.targets.should == [ "Specs" ]
  end

  describe "#install" do

    context "with an existing installation" do

      it "should remove the existing group from XCode"

      it "should add the new files to the project"

    end

    context "with a fresh installation" do

      it "should add the new files to the project"

    end

  end

  describe "#files" do

    let(:no_manifest_or_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "BingMapsIOS", :require => "MapControl") }
    let(:with_manifest) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-Manifest") }
    let(:with_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-Vendorspec") }

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      let(:files) { no_manifest_or_vendorspec.files }
      let(:names) { files.map { |file| File.basename(file) } }

      it "should return the correct files" do
        # This test is a little ugly, but meh, the Bing maps library has a good selection
        # of file types to test (including a ".a" and a ".bundle")
        ["BingMaps.h", "BMEntity.h", "BMGeometry.h", "BMMapView.h", "BMMarker.h",
         "BMMarkerView.h", "BMPushpinView.h", "BMReverseGeocoder.h", "BMTypes.h",
         "BMUserLocation.h", "BingMaps.Resources.bundle", "libBingMaps.a"].each do |file|
          names.should include(file)
        end
      end

      it "should return files in the correct location" do
        path = File.join(CACHED_VENDOR_RESOURCE_PATH, "base/BingMapsIOS/MapControl/")
        regex_path = /^#{path}.+$/

        files.each do |file|
          file.should =~ regex_path
        end
      end

      it "should return files that exist" do
        files.each do |file|
          File.exist?(file).should be_true
        end
      end

    end

    context "with a vendorspec" do

      let(:files) { with_vendorspec.files }
      let(:names) { files.map { |file| File.basename(file) } }

      it "should return the correct files" do
        ["DKBenchmark.h", "DKBenchmark.m"].each do |file|
          names.should include(file)
        end
      end

      it "should return files in the correct location" do
        path = File.join(CACHED_VENDOR_RESOURCE_PATH, "base/DKBenchmark-Vendorspec/")
        regex_path = /^#{path}.+$/

        files.each do |file|
          file.should =~ regex_path
        end
      end

      it "should return files that exist" do
        files.each do |file|
          File.exist?(file).should be_true
        end
      end

    end

    context "with a manifest" do

      let(:files) { with_manifest.files }
      let(:names) { files.map { |file| File.basename(file) } }

      it "should return the correct files" do
        ["DKBenchmark.h", "DKBenchmark.m"].each do |file|
          names.should include(file)
        end
      end

      it "should return files in the correct location" do
        path = File.join(CACHED_VENDOR_RESOURCE_PATH, "base/DKBenchmark-Manifest/data/")
        regex_path = /^#{path}.+$/

        files.each do |file|
          file.should =~ regex_path
        end
      end

      it "should return files that exist" do
        files.each do |file|
          File.exist?(file).should be_true
        end
      end

    end

  end

end
