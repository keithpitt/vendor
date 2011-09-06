require 'spec_helper'

describe VendorKit::XCode::Project do

  before :all do
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

  context '#add_file' do

    let(:first_file) { File.join(FILE_RESOURCE_PATH, "SecondViewController.h") }
    let(:second_file) { File.join(FILE_RESOURCE_PATH, "SecondViewController.m") }

    before :all do
      @temp_path = TempProject.create(File.join(PROJECT_RESOURCE_PATH, "ProjectWithSpecs"))
      @temp_project = VendorKit::XCode::Project.new(File.join(@temp_path, "ProjectWithSpecs.xcodeproj"))

      @temp_project.add_file :target => "Specs", :file => first_file, :path => "Controllers/SecondViewController"
      @temp_project.add_file :target => "Specs", :file => second_file, :path => "Controllers/SecondViewController"
    end

    it 'should add the file to the filesystem' do
      new_first_path = File.join(@temp_path, "Controllers", "SecondViewController", "SecondViewController.h")
      new_second_path = File.join(@temp_path, "Controllers", "SecondViewController", "SecondViewController.m")

      File.exists?(new_first_path).should be_true
      File.exists?(new_second_path).should be_true
    end

    it 'should add it as the correct file type'
    it 'should add it to the XCode project'
    it 'should add it to the build targets specified'

    context 'should raise an error if' do

      it 'there is no target set' do
        expect do
          @temp_project.add_file :file => "ASD", :path => "ASD"
        end.to raise_exception(StandardError, "Missing :target option")
      end

      it 'there is no path set' do
        expect do
          @temp_project.add_file :target => "Specs", :file => first_file
        end.to raise_exception(StandardError, "Missing :path option")
      end

      it 'there is no file set' do
        expect do
          @temp_project.add_file :target => "Specs", :path => "ASD"
        end.to raise_exception(StandardError, "Missing :file option")
      end

      it "the target doesn't exist" do
        expect do
          @temp_project.add_file :target => "Ruut", :file => second_file, :path => "Controllers/SecondViewController"
        end.to raise_exception(StandardError, "Could not find target `Ruut`")
      end

      it "the file doesn't exist" do
        expect do
          @temp_project.add_file :target => "Ruut", :file => "foo", :path => "Controllers/SecondViewController"
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
