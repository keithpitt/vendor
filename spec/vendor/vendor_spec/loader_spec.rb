require 'spec_helper'

describe Vendor::VendorSpec::Loader do

  let (:loader) { Vendor::VendorSpec::Loader.new }

  context "#initialize" do

    it "should create a dsl" do
      loader.dsl.should be_kind_of(Vendor::VendorSpec::DSL)
    end

  end

  context "#vendor" do

    it "should allow you to pass a block and define vendor spec properties" do
      loader.vendor do
        name "Something"
        files [ "Foo", "Bar" ]
      end

      loader.dsl.name.should == "Something"
      loader.dsl.files.should == [ "Foo", "Bar" ]
    end

  end

  context "#load" do

    it "should allow you to load from a file" do
      loader.load File.join(VENDOR_RESOURCE_PATH, "DKBenchmark", "DKBenchmark.vendorspec")

      loader.dsl.name.should == "DKBenchmark"
      loader.dsl.authors.should == "keithpitt"
      loader.dsl.email.should == "me@keithpitt.com"
    end

  end

end
