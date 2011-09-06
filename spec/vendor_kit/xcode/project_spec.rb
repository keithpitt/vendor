require 'spec_helper'

describe VendorKit::XCode::Project do

  before :each do
    @project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj"))
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
        project = VendorKit::XCode::Project.new(File.join(PROJECT_RESOURCE_PATH, "TabBarWithUnitTests/TabBarWithUnitTests.xcodeproj"))

        project.objects.length.should == 74
      end

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

  context '#find_and_make_group' do

    it "should return an existing group" do
      @project.find_and_make_group("Specs/Supporting Files").should == @project.root_object.main_group.children.first.children.first
    end

    it "should create a group if it doesn't exist" do
      group = @project.find_and_make_group("Specs/Supporting Files/Something/Goes Inside/Here")

      supporting_files_group = @project.root_object.main_group.children.first.children.first
      something_group = supporting_files_group.children.last
      inside_group = something_group.children.last
      here_group = inside_group.children.last

      something_group.name.should == "Something"
      inside_group.name.should == "Goes Inside"
      here_group.name.should == "Here"
      here_group.source_tree.should == "<group>"
    end

  end

  context '#add_file' do

    let(:first_file) { File.join(FILE_RESOURCE_PATH, "SecondViewController.h") }
    let(:second_file) { File.join(FILE_RESOURCE_PATH, "SecondViewController.m") }

    before :all do
      @temp_path = TempProject.create(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs"))
      @temp_project = VendorKit::XCode::Project.new(File.join(@temp_path, "ProjectWithSpecs.xcodeproj"))

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
      @first_file_added.path.should == "Controllers/SecondViewController/SecondViewController.h"
      @second_file_added.path.should == "Controllers/SecondViewController/SecondViewController.m"
    end

    it 'should add it to the correct group' do
      group = @temp_project.find_and_make_group("Controllers/SecondViewController")

      group.children[0].should == @first_file_added
      group.children[1].should == @second_file_added
    end

    it 'should add it to the build targets specified'

    context 'should raise an error if' do

      it 'there is no target set' do
        expect do
          @temp_project.add_file :file => "ASD", :path => "ASD"
        end.to raise_exception(StandardError, "Missing :targets option")
      end

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

  context "#to_ascii_plist" do

    it "should convert it to the correct format" do
      # Reload the project from the filesystem
      @project.reload

      contents = File.readlines(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs/ProjectWithSpecs.xcodeproj", "project.pbxproj")).join("\n")
      original = VendorKit::Plist.parse_ascii(contents)
      saved = VendorKit::Plist.parse_ascii(@project.to_ascii_plist)

      original.should == saved
    end

  end

end
