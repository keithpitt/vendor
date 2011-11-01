require 'spec_helper'

describe Vendor::VendorFile::Library::Git do

  it "should default the tag to 'master'" do
    lib = Vendor::VendorFile::Library::Git.new

    lib.tag.should == "master"
  end

  it "setting a branch should set the tag" do
    lib = Vendor::VendorFile::Library::Git.new(:branch => "develop")

    lib.tag.should == "develop"
  end

  it "setting a ref should set the tag" do
    lib = Vendor::VendorFile::Library::Git.new(:ref => "3g34g34")

    lib.tag.should == "3g34g34"
  end

  describe "#cache_path" do

    it "should use a hash for the repo url, instead of the name of the lib" do
      lib = Vendor::VendorFile::Library::Git.new(:git => "git@github.com:/foo/bar")

      lib.cache_path.should == File.join(Vendor.library_path, "git", "a77462af23c7ce7d5599c5428e41a11b")
    end

  end

end
