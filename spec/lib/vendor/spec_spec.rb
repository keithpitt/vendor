require 'spec_helper'

describe Vendor::Spec do

  let! (:spec) { Vendor::Spec.new }

  context '#validate' do

    before :each do
      spec.name = "Vendor"
      spec.files = "Something"
      spec.email = "foo@bar.com"
      spec.version = "0.1"
    end

    it 'should thorw an error if no name is defined' do
      expect do
        spec.name = nil
        spec.validate!
      end.should raise_error("Specification is missing the `name` option")
    end

    it 'should thorw an error if no email is defined' do
      expect do
        spec.email = nil
        spec.validate!
      end.should raise_error("Specification is missing the `email` option")
    end

    it 'should thorw an error if no version is defined' do
      expect do
        spec.version = nil
        spec.validate!
      end.should raise_error("Specification is missing the `version` option")
    end

    it 'should thorw an error if no files are defined' do
      expect do
        spec.files = nil
        spec.validate!
      end.should raise_error("Specification is missing the `files` option")
    end

  end

  context '#to_json' do

    it 'should return the vendor spec as a JSON string' do
      spec.name = "foo"
      spec.to_json.should == { :name => "foo" }.to_json
    end

  end

end
