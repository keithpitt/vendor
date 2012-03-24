require 'spec_helper'

describe Vendor::VendorFile::Library::Base do

  let(:temp_path) { TempProject.create(File.join(PROJECT_RESOURCE_PATH, "MultipleTargets")) }
  let(:project) { Vendor::XCode::Project.new(File.join(temp_path, "MultipleTargets.xcodeproj")) }

  let(:lib) { Vendor::VendorFile::Library::Base.new(:name => "ExampleLib") }

  let(:lib_with_no_manifest_or_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "BingMapsIOS", :require => "MapControl", :target => "MultipleTargets") }
  let(:lib_with_manifest) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-0.1-Manifest", :targets => [ "MultipleTargets", "Specs" ]) }
  let(:lib_with_vendorspec) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-0.1-Vendorspec", :target => "MultipleTargets") }
  let(:lib_with_nothing) { Vendor::VendorFile::Library::Base.new(:name => "DKBenchmark-0.1-Nothing", :target => "MultipleTargets") }

  it "should have a name attribute" do
    lib.name = "lib"

    lib.name.should == "lib"
  end

  it "should have a target attribute" do
    lib.targets = "Specs"

    lib.targets.should == [ "Specs" ]
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
        dependencies[0].targets.should == [ "MultipleTargets" ]

        dependencies[1].name.should == "ASIHTTPRequest"
        dependencies[1].equality.should == "~>"
        dependencies[1].version.should == "4.2"
        dependencies[1].targets.should == [ "MultipleTargets" ]

        dependencies[2].name.should == "AFINetworking"
        dependencies[2].equality.should == "<="
        dependencies[2].version.should == "2.5.a"
        dependencies[2].parent.should == lib_with_vendorspec
        dependencies[2].targets.should == [ "MultipleTargets" ]
      end

    end

    context "with a manifest" do

      let(:dependencies) { lib_with_manifest.dependencies }

      it "should return the correct dependencies" do
        dependencies[0].name.should == "JSONKit"
        dependencies[0].version.should == "0.3"
        dependencies[0].parent.should == lib_with_manifest
        dependencies[0].targets.should == [ "MultipleTargets", "Specs" ]

        dependencies[1].name.should == "ASIHTTPRequest"
        dependencies[1].equality.should == "~>"
        dependencies[1].version.should == "4.3"
        dependencies[1].parent.should == lib_with_manifest
        dependencies[1].targets.should == [ "MultipleTargets", "Specs" ]

        dependencies[2].name.should == "AFINetworking"
        dependencies[2].equality.should == "<="
        dependencies[2].version.should == "2.5.b"
        dependencies[2].parent.should == lib_with_manifest
        dependencies[2].targets.should == [ "MultipleTargets", "Specs" ]

      end

    end

    context "with no dependencies" do

      it "should return an empty array" do
        lib_with_nothing.dependencies.should == []
      end

    end

  end

  describe "#frameworks" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      it "should have no frameworks" do
        lib_with_no_manifest_or_vendorspec.frameworks.should be_empty
      end

    end

    context "with a vendorspec" do

      it "should have frameworks" do
        lib_with_vendorspec.frameworks.should == [ "Foundation.framework" ]
      end

    end

    context "with a manifest" do

      it "should have frameworks" do
        lib_with_manifest.frameworks.should == [ "CoreData.framework" ]
      end

    end

    context "with no frameworks" do

      it "should return an empty array" do
        lib_with_nothing.frameworks.should == []
      end

    end

  end

  describe "#build_settings" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      it "should have no build_settings" do
        lib_with_no_manifest_or_vendorspec.build_settings.should be_empty
      end

    end

    context "with a vendorspec" do

      it "should have build_settings" do
        lib_with_vendorspec.build_settings.should == [ [ "OTHER_LDFLAGS", "-ObjC" ] ]
      end

    end

    context "with a manifest" do

      it "should have build_settings" do
        lib_with_manifest.build_settings.should == [ [ "CLANG_WARN_OBJCPP_ARC_ABI", "NO" ] ]
      end

    end

    context "with no build settings" do

      it "should return an empty array" do
        lib_with_nothing.build_settings.should == []
      end

    end

  end

  describe "#per_file_flag" do

    before :each do
      Vendor.stub(:library_path).and_return CACHED_VENDOR_RESOURCE_PATH
    end

    context "with no manifest or vendorspec" do

      it "should have no per_file_flag" do
        lib_with_no_manifest_or_vendorspec.per_file_flag.should be_nil
      end

    end

    context "with a vendorspec" do

      it "should have per_file_flag" do
        lib_with_vendorspec.per_file_flag.should == "-fno-objc-arc"
      end

    end

    context "with a manifest" do

      it "should have per_file_flag" do
        lib_with_manifest.per_file_flag.should == "-fno-objc-arc"
      end

    end

    context "with no per file settings" do

      it "should be nil" do
        lib_with_nothing.per_file_flag.should be_nil
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
