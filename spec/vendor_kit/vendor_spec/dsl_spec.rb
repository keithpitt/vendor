require 'spec_helper'

describe VendorKit::VendorSpec::DSL do

  let! (:dsl) { VendorKit::VendorSpec::DSL.new }

  context '#vendor_spec' do

    it 'should load all the properties into the vendor spec' do
      dsl.foo "foo"
      dsl.cheese "is good"

      dsl.vendor_spec.should == { :foo => "foo", :cheese => "is good" }
    end

  end

  context '#validate' do

    before :each do
      dsl.name = "VendorKit"
      dsl.files = "Something"
      dsl.email = "foo@bar.com"
      dsl.version = "0.1"
    end

    it 'should thorw an error if no name is defined' do
      expect do
        dsl.name = nil
        dsl.validate!
      end.should raise_error("Specification is missing the `name` option")
    end

    it 'should thorw an error if no email is defined' do
      expect do
        dsl.email = nil
        dsl.validate!
      end.should raise_error("Specification is missing the `email` option")
    end

    it 'should thorw an error if no version is defined' do
      expect do
        dsl.version = nil
        dsl.validate!
      end.should raise_error("Specification is missing the `version` option")
    end

    it 'should thorw an error if no files are defined' do
      expect do
        dsl.files = nil
        dsl.validate!
      end.should raise_error("Specification is missing the `files` option")
    end

  end

  context '#to_json' do

    it 'should return the vendor spec as a JSON string' do
      dsl.foo "foo"

      dsl.to_json.should == dsl.vendor_spec.to_json
    end

  end

end
