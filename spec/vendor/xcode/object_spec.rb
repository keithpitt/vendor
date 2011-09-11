require 'spec_helper'

describe Vendor::XCode::Object do

  before :all do
    @project = Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj"))
    @pbx_project = @project.root_object
  end

  context "#inspect" do

    it "should give you the attributes in the object" do
      @pbx_project.build_configuration_list.inspect.should include("Vendor::XCode::Objects::XCConfigurationList")
      @pbx_project.build_configuration_list.inspect.should include("id: \"53787482140109AE00D9B746\"")
      @pbx_project.build_configuration_list.inspect.should include("build_configurations: [\"53787484140109AE00D9B746\", \"53787485140109AE00D9B746\"]")
      @pbx_project.build_configuration_list.inspect.should include("default_configuration_is_visible: \"0\"")
      @pbx_project.build_configuration_list.inspect.should include("default_configuration_name: \"Release\"")
    end

  end

  context "#attribute_name"do

    it "should convert the attribute to the correct format used in the project file (camel case)" do
      Vendor::XCode::Object.attribute_name('build_config_list').should == "buildConfigList"
    end

  end

  context "#method_missing" do

    it "should allow you to access attributes using an underscore case" do
      @pbx_project.known_regions.should == [ "en" ]
    end

    it "should allow you to set attributes using an underscore case" do
      @pbx_project.known_regions = [ "fn" ]

      @pbx_project.known_regions.should == [ "fn" ]
    end

  end

  context "#write_attribute" do

    it "should allow you to set existing attributes" do
      @pbx_project.write_attribute('knownRegions', [ "en" ])
    end

    it "should allow symbols to be passed" do
      @pbx_project.write_attribute(:knownRegions, [ "en" ])
    end

    after :each do
      @pbx_project.known_regions.should == [ "en" ]
    end

  end

  context "#read_attribute" do

    before :each do
      @pbx_project.known_regions = [ 'uk' ]
    end

    it "should allow you to read an attribute" do
      @pbx_project.read_attribute('knownRegions').should == [ 'uk' ]
    end

    it 'should allow symbols to be used' do
      @pbx_project.read_attribute(:knownRegions).should == [ 'uk' ]
    end

  end

end
