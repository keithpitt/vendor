require 'spec_helper'

describe Vendor::XCode::Proxy::PBXGroup do

  before :all do
    @project = Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "UtilityApplication/UtilityApplication.xcodeproj"))

    @pbx_group = @project.find_group("UtilityApplication/Supporting Files")
  end

  describe "#parent" do

    it "should return the parent of the group" do
      @pbx_group.parent.should == @project.find_group("UtilityApplication")
    end

  end

  describe "#full_path" do

    it "should return the path of the group" do
      @pbx_group.full_path.should == "UtilityApplication/Supporting Files"
    end

  end

end
