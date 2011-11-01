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

    let(:bing_library) { Vendor::VendorFile::Library::Base.new(:name => "BingMapsIOS", :require => "MapControl") }

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      it "should return the correct files" do
        names = bing_library.files.map { |file| File.basename(file) }

        # This test is a little ugly, but meh, the Bing maps library has a good selection
        # of file types to test (including a ".a" and a ".bundle")
        ["BingMaps.h", "BMEntity.h", "BMGeometry.h", "BMMapView.h", "BMMarker.h",
         "BMMarkerView.h", "BMPushpinView.h", "BMReverseGeocoder.h", "BMTypes.h",
         "BMUserLocation.h", "BingMaps.Resources.bundle", "libBingMaps.a"].each do |file|
          names.should include(file)
        end
      end

    end

    context "with a vendorspec" do

      it "should return the correct files" do

      end

    end

    context "with a manifest" do

      it "should return the correct files" do

      end

    end

  end

end
