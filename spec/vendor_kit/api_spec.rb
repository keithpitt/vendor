require 'spec_helper'

describe VendorKit::API do

  context "#api_key" do

    it "should raise an error if the server returns a 401" do
      expect do
        VendorKit::API.api_key("keithpitt", "wrong")
      end.should raise_error(VendorKit::API::Error, "Login or password is incorrect")
    end

    it "should raise an error if the server returns a non 200" do
      expect do
        VendorKit::API.api_key("keithpitt", "error")
      end.should raise_error(VendorKit::API::Error, "Could not download API key from server. Server returned a staus code of 500")
    end

    it "should return an API key if the server returns a 200" do
      VendorKit::API.api_key("keithpitt", "password").should == "secret"
    end

  end

end
