require 'spec_helper'

describe Vendor::Template do

  context "#directory" do

    let(:template) { File.join(Vendor.root, "vendor", "templates", "Vendorfile") }
    let(:target) { File.join(File.expand_path(Dir.pwd), "Vendorfile") }

    it "should copy a file to the current directory" do
      FileUtils.should_receive(:copy).with(template, target)

      Vendor::Template.copy "Vendorfile"
    end

    it "should not copy if the file already exists" do
      File.should_receive(:exist?).with(target).and_return(true)
      FileUtils.should_not_receive(:copy).with(template, target)

      Vendor::Template.copy "Vendorfile"
    end

  end

end
