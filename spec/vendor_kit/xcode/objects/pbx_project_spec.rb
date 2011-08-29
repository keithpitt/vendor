require 'spec_helper'

describe VendorKit::XCode::Project do

  before :all do
    @project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj"))
    @pbx_project = @project.root_object
  end

  it "should reference the build configuration list" do
    @pbx_project.buildConfigurationList.should == @project.find_object('53787482140109AE00D9B746')
  end

end
