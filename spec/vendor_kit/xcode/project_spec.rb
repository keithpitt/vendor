require 'spec_helper'

describe VendorKit::XCode::Project do

  before :all do
    @project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj"))
  end

  context "#initialize" do

    context "ProjectWithSpecs.xcodeproj" do

      it "should load all the objects" do
        @project.objects.length.should == 48
      end

      it "should load the object version" do
        @project.object_version.should == 46
      end

      it "should load the archive version" do
        @project.archive_version.should == 1
      end

      it "should populate the root object" do
        @project.root_object.should_not be_nil
      end

    end

    context "TabBarWithUnitTests.xcodeproj" do

      it "should parse and load all the objects" do
        project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "TabBarWithUnitTests.xcodeproj"))

        project.objects.length.should == 74
      end

    end

  end

  context "#find_object" do

    it "should return the object mapped to the id" do
      @project.find_object('5378747F140109AE00D9B746').should == @project.root_object
    end

  end

  context "#to_ascii_plist" do

    it "should convert it to the correct format" do
      # Reload the project from the filesystem
      @project.reload

      contents = File.readlines(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs.xcodeproj", "project.pbxproj")).join("\n")
      original = VendorKit::Plist.parse_ascii(contents)
      saved = VendorKit::Plist.parse_ascii(@project.to_ascii_plist)

      original.should == saved
    end

  end

end
