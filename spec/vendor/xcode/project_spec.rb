require 'spec_helper'

describe Vendor::XCode::Project do

  before :each do
    @project = Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj"))
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
        project = Vendor::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "TabBarWithUnitTests/TabBarWithUnitTests.xcodeproj"))

        project.objects.length.should == 78
      end

    end

  end

  context "#name" do

    it "should have the correct project name" do
      @project.name.should == "ProjectWithSpecs"
    end

  end

  context "#find_object" do

    it "should return the object mapped to the id" do
      @project.find_object('5378747F140109AE00D9B746').should == @project.root_object
    end

  end

  context "#find_target" do

    it "should return the target" do
      @project.find_target('Specs').should == @project.root_object.targets.first
    end

    it "should return nil if one cannot be found" do
      @project.find_target('Ruut').should be_nil
    end

  end

  context "#find_group" do

    context 'when finding an existing group' do

      it "should return the group" do
        @project.find_group("Specs/Supporting Files").should == @project.root_object.main_group.children.first.children.first
      end

    end

    context "when looking for a group that doens't exist" do

      it "should return nil" do
        @project.find_group("Does/Not/Exist").should == nil
      end

    end

  end

  context '#create_group' do

    context 'when finding an existing group' do

      it "should return the group" do
        @project.create_group("Specs/Supporting Files").should == @project.root_object.main_group.children.first.children.first
      end

    end

    context 'when creating a group' do

      before :each do
        @group = @project.create_group("Specs/Supporting Files/Something/Goes Inside/Here")

        @supporting_files_group = @project.root_object.main_group.children.first.children.first
        @something_group = @supporting_files_group.children.last
        @inside_group = @something_group.children.last
        @here_group = @inside_group.children.last
      end

      it 'should create it in the correct location' do
        @here_group.should_not be_nil
      end

      it 'should give the new groups the right names' do
        @something_group.name.should == "Something"
        @inside_group.name.should == "Goes Inside"
        @here_group.name.should == "Here"
      end

      it 'should give the new groups the correct source tree property' do
        @here_group.source_tree.should == "<group>"
      end

      it 'should give the new groups an ID' do
        @here_group.source_tree.should_not be_nil
      end

      it 'should give the new groups a valid ISA' do
        @here_group.isa.should == 'PBXGroup'
      end

    end

  end

  context "#remove_group" do

    before :each do
      @temp_path = TempProject.create(File.join(PROJECT_RESOURCE_PATH, "UtilityApplication"))
      @temp_project = Vendor::XCode::Project.new(File.join(@temp_path, "UtilityApplication.xcodeproj"))

      @group = @temp_project.find_group("UtilityApplication/Supporting Files")
    end

    context "removing an existing group" do

      it "should return true" do
        remove_group.should be_true
      end

      it "should remove the group" do
        @project.find_group("UtilityApplication/Supporting Files").should be_nil
      end

      it "should remove the files from the file system" do
        file = File.join(@temp_path, "UtilityApplication", "main.m")
        File.exist?(file).should be_true

        remove_group
        File.exist?(file).should be_false
      end

      it "should remove the files from the build targets"

      private

        def remove_group
          @temp_project.remove_group("UtilityApplication/Supporting Files")
        end

    end

    context "removing a group that doesn't exist" do

      subject { @temp_project.remove_group("Doest/Not/Exist") }

      it "should return false" do
        subject.should be_false
      end

    end

  end

  context "#remove_file"

  context '#add_file' do

    let(:first_file) { File.join(SOURCE_RESOURCE_PATH, "SecondViewController.h") }
    let(:second_file) { File.join(SOURCE_RESOURCE_PATH, "SecondViewController.m") }

    before :each do
      @temp_path = TempProject.create(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs"))
      @temp_project = Vendor::XCode::Project.new(File.join(@temp_path, "ProjectWithSpecs.xcodeproj"))

      @target = @temp_project.find_target("Specs")

      @first_file_added = @temp_project.add_file :targets => [ @target ], :file => first_file, :path => "Controllers/SecondViewController"
      @second_file_added = @temp_project.add_file :targets => [ @target ], :file => second_file, :path => "Controllers/SecondViewController"
    end

    it 'should add the file to the filesystem' do
      new_first_path = File.join(@temp_path, "Controllers", "SecondViewController", "SecondViewController.h")
      new_second_path = File.join(@temp_path, "Controllers", "SecondViewController", "SecondViewController.m")

      File.exists?(new_first_path).should be_true
      File.exists?(new_second_path).should be_true
    end

    it 'should add it as the correct file type' do
      @first_file_added.last_known_file_type.should == "sourcecode.c.h"
      @second_file_added.last_known_file_type.should == "sourcecode.c.objc"
    end

    it 'should add the files with the correct path' do
      @first_file_added.path.should == "SecondViewController.h"
      @second_file_added.path.should == "SecondViewController.m"
    end

    it 'should have the correct ISA' do
      @first_file_added.isa.should == "PBXFileReference"
      @second_file_added.isa.should == "PBXFileReference"
    end

    it 'should have an ID' do
      @first_file_added.id.should_not be_nil
      @second_file_added.id.should_not be_nil
    end

    it 'should add it to the correct group' do
      group = @temp_project.create_group("Controllers/SecondViewController")

      group.children[0].should == @first_file_added
      group.children[1].should == @second_file_added
    end

    it 'should still save' do
      @temp_project.save
    end

    it 'should add it to the build targets specified'

    context 'should raise an error if' do

      it 'there is no path set' do
        expect do
          @temp_project.add_file :targets => "Specs", :file => first_file
        end.to raise_exception(StandardError, "Missing :path option")
      end

      it 'there is no file set' do
        expect do
          @temp_project.add_file :targets => "Specs", :path => "ASD"
        end.to raise_exception(StandardError, "Missing :file option")
      end

      it "the file doesn't exist" do
        expect do
          @temp_project.add_file :targets => "Ruut", :file => "foo", :path => "Controllers/SecondViewController"
        end.to raise_exception(StandardError, "Could not find file `foo`")
      end

    end

  end

  context "#valid?" do

    it "should return true the plist format is valid" do
      @project.valid?.should be_true
    end

    it "should raise an error if there is an invalid format" do
      @project.should_receive(:to_ascii_plist).and_return { "asd; { fasdfas" }

      @project.valid?.should be_false
    end

  end

  context "#to_ascii_plist" do

    it "should convert it to the correct format" do
      # Reload the project from the filesystem
      @project.reload

      contents = File.readlines(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj", "project.pbxproj")).join("\n")
      original = Vendor::Plist.parse_ascii(contents)
      saved = Vendor::Plist.parse_ascii(@project.to_ascii_plist)

      original.should == saved
    end

  end

end
