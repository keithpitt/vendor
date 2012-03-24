require 'spec_helper'

describe Vendor::Spec do

  let! (:spec) { Vendor::Spec.new }

  context "#load" do

    let(:spec_file) { File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.vendorspec") }

    it "should return the loaded spec" do
      Vendor::Spec.load(spec_file).should be_kind_of(Vendor::Spec)
    end

    it "should switch back in and out of the current directory using Dir.chdir while evaling the spec" do
      current_dir = Dir.pwd
      Dir.should_receive(:chdir).with(File.join(VENDOR_RESOURCE_PATH, "DKBenchmark")).ordered
      Dir.should_receive(:chdir).with(current_dir).ordered

      Vendor::Spec.load(spec_file).should be_kind_of(Vendor::Spec)
    end

  end

  context '#validate' do

    before :each do
      spec.name = "Vendor"
      spec.files = "Something"
      spec.email = "foo@bar.com"
      spec.version = "0.1"
    end

    it 'should thorw an error if no name is defined' do
      expect do
        spec.name = nil
        spec.validate!
      end.should raise_error("Specification is missing the `name` option")
    end

    it 'should thorw an error if no email is defined' do
      expect do
        spec.email = nil
        spec.validate!
      end.should raise_error("Specification is missing the `email` option")
    end

    it 'should thorw an error if no version is defined' do
      expect do
        spec.version = nil
        spec.validate!
      end.should raise_error("Specification is missing the `version` option")
    end

    it 'should thorw an error if no files are defined' do
      expect do
        spec.files = nil
        spec.validate!
      end.should raise_error("Specification is missing the `files` option")
    end

  end

  context "#framework" do

    it "should add the framework to the frameworks property" do
      spec.framework "Foundation.framework"

      spec.frameworks.should == [ "Foundation.framework" ]
    end

  end

  context "#build_setting" do

    it "should set a build setting" do
      spec.build_setting "SOMETHING", "else"

      spec.build_settings.should == [ [ "SOMETHING", "else" ] ]
    end

    it "should allow you to remap names with a symbol" do
      spec.build_setting :other_linker_flags, "-ObjC"

      spec.build_settings.should == [ [ :other_linker_flags, "-ObjC" ] ]
    end

    it "should turn the value to YES if you pass true" do
      spec.build_setting :other_linker_flags, true
      spec.build_setting :other_linker_flags, false

      spec.build_settings.should == [ [ :other_linker_flags, true ], [ :other_linker_flags, false ] ]
    end

  end

  context "#per_file_flag" do
    
    it "should set a per file flag" do
      spec.per_file_flag "-fno-objc-arc"
      
      spec.per_file_flag.should == "-fno-objc-arc"
    end
    
  end
  
  context '#to_json' do

    it 'should return the vendor spec as a JSON string' do
      spec.name = "foo"
      spec.framework "Foundation.framework"
      spec.build_setting :other_linker_flags, true
      spec.dependency "JSONKit", "0.5"

      json = JSON.parse(spec.to_json)

      json["name"].should == "foo"
      json["dependencies"].should == [ [ "JSONKit", "0.5" ] ]
      json["frameworks"].should == [ "Foundation.framework" ]
      json["build_settings"].should == [ [ "other_linker_flags", true ] ]
    end

  end

end
