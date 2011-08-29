require 'spec_helper'

describe VendorKit::XCode::Proxy do

  context "#initialize" do

    context "ProjectWithSpecs.xcodeproj" do

      before :all do
        @project = VendorKit::XCode::Proxy.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj"))
      end

      it "should load all the objects" do
        @project.objects.length.should == 48
      end

      it "should load the object version" do
        @project.object_version.should == 46
      end

      it "should load the archive version" do
        @project.archive_version.should == 1
      end

    end

  end

end
