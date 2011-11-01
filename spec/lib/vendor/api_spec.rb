require 'spec_helper'

describe Vendor::API do

  context "#api_key" do

    it "should raise an error if the server returns a 401" do
      expect do
        Vendor::API.api_key("keithpitt", "wrong")
      end.should raise_error(Vendor::API::Error, "Login or password is incorrect")
    end

    it "should raise an error if the server returns a non 200" do
      expect do
        Vendor::API.api_key("keithpitt", "error")
      end.should raise_error(Vendor::API::Error, "Could not complete request. Server returned a status code of 500")
    end

    it "should return an API key if the server returns a 200" do
      Vendor::API.api_key("keithpitt", "password").should == "secret"
    end

  end

end
