require 'spec_helper'

describe Vendor::VendorFile::Library::Base do

  let(:lib) { Vendor::VendorFile::Library::Base.new(:name => "ExampleLib") }

  let(:temp_path) { TempProject.create(File.join(PROJECT_RESOURCE_PATH, "UtilityApplication")) }
  let(:project) { Vendor::XCode::Project.new(File.join(temp_path, "UtilityApplication.xcodeproj")) }

  let(:lib_with_no_manifest_or_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "BingMapsIOS", :require => "MapControl") }
  let(:lib_with_manifest) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-0.1-Manifest") }
  let(:lib_with_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-0.1-Vendorspec") }

  it "should have a name attribute" do
    lib.name = "lib"

    lib.name.should == "lib"
  end

  it "should have a target attribute" do
    lib.targets = "Specs"

    lib.targets.should == [ "Specs" ]
  end

  describe "#install" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH

      lib_with_manifest.install project
    end

    context "with an existing installation" do

      before :each do
        # Install it again
        lib_with_manifest.install project
      end

      it "should add the group to the project" do
        group = project.find_group("Vendor/DKBenchmark-0.1-Manifest")
        group.should_not be_nil
      end

      it "should add the files to the project" do
        children = project.find_group("Vendor/DKBenchmark-0.1-Manifest").children
        children.length.should == 2
      end

    end

    context "with a fresh installation" do

      it "should add the group to the project" do
        group = project.find_group("Vendor/DKBenchmark-0.1-Manifest")
        group.should_not be_nil
      end

      it "should add the files to the project" do
        children = project.find_group("Vendor/DKBenchmark-0.1-Manifest").children
        children.length.should == 2
      end

    end

  end

  describe "#cache_path" do

    it "should return the location where the lib is to be stored" do
      lib.cache_path.should == File.join(Vendor.library_path, "base", "ExampleLib")
    end

  end

  describe "#dependencies" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      it "should return no dependencies" do
        lib_with_no_manifest_or_vendorspec.dependencies.should be_empty
      end

    end

    context "with a vendorspec" do

      let(:dependencies) { lib_with_vendorspec.dependencies }

      it "should return the correct dependencies" do
        dependencies[0].name.should == "JSONKit"
        dependencies[0].version.should == "0.5"
        dependencies[0].parent.should == lib_with_vendorspec

        dependencies[1].name.should == "ASIHTTPRequest"
        dependencies[1].equality.should == "~>"
        dependencies[1].version.should == "4.2"
        dependencies[1].parent.should == lib_with_vendorspec

        dependencies[2].name.should == "AFINetworking"
        dependencies[2].equality.should == "<="
        dependencies[2].version.should == "2.5.a"
        dependencies[2].parent.should == lib_with_vendorspec
      end

    end

    context "with a manifest" do

      let(:dependencies) { lib_with_manifest.dependencies }

      it "should return the correct dependencies" do
        dependencies[0].name.should == "JSONKit"
        dependencies[0].version.should == "0.3"
        dependencies[0].parent.should == lib_with_manifest

        dependencies[1].name.should == "ASIHTTPRequest"
        dependencies[1].equality.should == "~>"
        dependencies[1].version.should == "4.3"
        dependencies[1].parent.should == lib_with_manifest

        dependencies[2].name.should == "AFINetworking"
        dependencies[2].equality.should == "<="
        dependencies[2].version.should == "2.5.b"
        dependencies[2].parent.should == lib_with_manifest
      end

    end

  end

  describe "#files" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      let(:files) { lib_with_no_manifest_or_vendorspec.files }
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

      let(:files) { lib_with_vendorspec.files }
      let(:names) { files.map { |file| File.basename(file) } }

      it "should return the correct files" do
        ["DKBenchmark.h", "DKBenchmark.m"].each do |file|
          names.should include(file)
        end
      end

      it "should return files in the correct location" do
        path = File.join(CACHED_VENDOR_RESOURCE_PATH, "base/DKBenchmark-0.1-Vendorspec/")
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

      let(:files) { lib_with_manifest.files }
      let(:names) { files.map { |file| File.basename(file) } }

      it "should return the correct files" do
        ["DKBenchmark.h", "DKBenchmark.m"].each do |file|
          names.should include(file)
        end
      end

      it "should return files in the correct location" do
        path = File.join(CACHED_VENDOR_RESOURCE_PATH, "base/DKBenchmark-0.1-Manifest/data/")
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
