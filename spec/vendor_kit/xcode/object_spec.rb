require 'spec_helper'

describe VendorKit::XCode::Project do

  before :all do
    @project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj"))
    @pbx_project = @project.root_object
  end

  it "should inspect nicely" do
    @pbx_project.buildConfigurationList.inspect.should == "#<VendorKit::XCode::Objects::XCConfigurationList id: \"53787482140109AE00D9B746\", isa: \"XCConfigurationList\", defaultConfigurationIsVisible: \"0\", defaultConfigurationName: \"Release\", buildConfigurations: [\"53787484140109AE00D9B746\", \"53787485140109AE00D9B746\"]>"
  end

end
