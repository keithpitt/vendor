require 'spec_helper'

describe Vendor::Template do

  let(:template) { File.join(Vendor.root, "vendor", "templates", "Vendorfile") }
  let(:target) { File.join(File.expand_path(Dir.pwd), "Vendorfile") }
  let(:contents) { File.read(template) }

  context "#copy" do

    it "should write a file to the current directory" do
      file = mock('file')
      File.should_receive(:open).with(target, "w").and_yield(file)
      file.should_receive(:write).with(contents)

      Vendor::Template.copy "Vendorfile"
    end

    it "should not copy if the file already exists" do
      File.should_receive(:exist?).with(target).and_return(true)
      File.should_not_receive(:open)

      Vendor::Template.copy "Vendorfile"
    end

  end

  context "#parse" do

    it "should parse ERB" do
      Vendor::Template.parse("This is <%= foo %>", :foo => "awesome!").should == "This is awesome!"
    end

  end

end
