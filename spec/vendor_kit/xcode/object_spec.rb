require 'spec_helper'

describe VendorKit::XCode::Object do

  before :all do
    @project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj"))
    @pbx_project = @project.root_object
  end

  context "#inspect" do

    it "should give you the attributes in the object" do
      @pbx_project.build_configuration_list.inspect.should == "#<VendorKit::XCode::Objects::XCConfigurationList id: \"53787482140109AE00D9B746\", isa: \"XCConfigurationList\", defaultConfigurationIsVisible: \"0\", defaultConfigurationName: \"Release\", buildConfigurations: [\"53787484140109AE00D9B746\", \"53787485140109AE00D9B746\"]>"
    end

  end

  context "#attribute_name"do

    it "should convert the attribute to the correct format used in the project file (camel case)" do
      VendorKit::XCode::Object.attribute_name('build_config_list').should == "buildConfigList"
    end

  end

end
