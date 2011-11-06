require 'spec_helper'

describe Vendor::VendorFile::Loader do

  let (:loader) { Vendor::VendorFile::Loader.new }

  context "#initialize" do

    it "should create a dsl" do
      loader.dsl.should be_kind_of(Vendor::VendorFile::DSL)
    end

  end

  context "#dependency_graph" do

    before :all do
      loader.dsl.libraries << Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "~> 0.1")
    end

    it "should have a matrix of dependencies"

  end

  context "#load" do

    before :all do
      loader.load File.join(RESOURCE_PATH, "Vendorfile")

      @sources = loader.dsl.sources
      @libs = loader.dsl.libraries
    end

    it "should load all the sources" do
      @sources.map(&:uri).should == [ "http://vendorforge.com", "http://vendorage.com" ]
    end

    it "should load all the libraries" do
      @libs.count.should == 13
    end

    it "should load remote librarires" do
      @libs[0].name.should == "Lib"
      @libs[0].version.should be_nil
      @libs[0].should be_kind_of(Vendor::VendorFile::Library::Remote)

      @libs[1].name.should == "LibWithVersion"
      @libs[1].version.should == "4.1"
      @libs[1].should be_kind_of(Vendor::VendorFile::Library::Remote)

      @libs[2].name.should == "LibWithGreaterThanVersion"
      @libs[2].version.should == "1.0"
      @libs[2].equality.should == ">="
      @libs[2].should be_kind_of(Vendor::VendorFile::Library::Remote)

      @libs[3].name.should == "LibWithApproxVersionAndTarget"
      @libs[3].version.should == "1.0"
      @libs[3].equality.should == "~>"
      @libs[3].targets.should == [ "something" ]
      @libs[3].should be_kind_of(Vendor::VendorFile::Library::Remote)
    end

    it "should load all the git libraries" do
      @libs[4].name.should == "LibWithGit"
      @libs[4].uri.should == "https://github.com/keithpitt/vendor.git"
      @libs[4].tag.should == "master"
      @libs[4].require.should == "Some/Folder"
      @libs[4].should be_kind_of(Vendor::VendorFile::Library::Git)

      @libs[5].name.should == "LibWithGitAndBranch"
      @libs[5].uri.should == "https://github.com/keithpitt/vendor.git"
      @libs[5].tag.should == "1.4"
      @libs[5].should be_kind_of(Vendor::VendorFile::Library::Git)

      @libs[6].name.should == "LibWithGitAndTag"
      @libs[6].uri.should == "https://github.com/keithpitt/vendor.git"
      @libs[6].tag.should == "v0.13.4"
      @libs[6].should be_kind_of(Vendor::VendorFile::Library::Git)

      @libs[7].name.should == "LibWithGitAndRef"
      @libs[7].uri.should == "https://github.com/keithpitt/vendor.git"
      @libs[7].tag.should == "some-ref"
      @libs[7].should be_kind_of(Vendor::VendorFile::Library::Git)
    end

    it "should load all the local libraries" do
      @libs[8].name.should == "LibWithPath"
      @libs[8].path.should == "~/Development/Library/Path"
      @libs[8].should be_kind_of(Vendor::VendorFile::Library::Local)
    end

    it "should load all the libraries with a specific target" do
      @libs[9].name.should == "LibWithSpecificTarget"
      @libs[9].version.should be_nil
      @libs[9].targets.should == [ "UISpecs" ]

      @libs[10].name.should == "LibWithMultipleTarget"
      @libs[10].version.should be_nil
      @libs[10].targets.should == [ "Specs", "UISpecs" ]
    end

    it "should load all libraries within a target" do
      @libs[11].name.should == "SpecLib1"
      @libs[11].version.should be_nil
      @libs[11].targets.should == [ "Specs", "UISpecs" ]

      @libs[12].name.should == "SpecLib2"
      @libs[12].version.should be_nil
      @libs[12].targets.should == [ "Specs", "UISpecs" ]
    end

  end

end
