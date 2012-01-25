require 'spec_helper'

describe Vendor::XCode::Proxy::PBXProject do

  before :all do
    @project = Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj"))
    @pbx_project = @project.root_object
  end

  it "should reference the build configuration list" do
    @pbx_project.build_configuration_list.should == @project.find_object('53787482140109AE00D9B746')
  end

  it "should reference the product reference group" do
    @pbx_project.product_ref_group.should == @project.find_object('537874A014010A0A00D9B746')
  end

  it "should reference the main group" do
    @pbx_project.main_group.should == @project.find_object('5378747D140109AE00D9B746')
  end

  it "should reference the targets" do
    @pbx_project.targets.should == [
      @project.find_object("5378749E14010A0A00D9B746"),
      @project.find_object("53BD73C714D0AF9A00E30313")
    ]
  end

end
