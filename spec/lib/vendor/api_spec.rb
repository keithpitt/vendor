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

  context "#meta" do

    it "should download information about the vendor in JSON format" do
      json = Vendor::API.meta("DKBenchmark")

      json["name"].should == "DKBenchmark"
      json["description"].should == "Easy benchmarking in Objective-C using blocks"
      json["release"].should == "0.2"
      json["versions"].first[0].should == "0.3.alpha1"
    end

    it "should download information with vendors that had odd names" do
      json = Vendor::API.meta("DKBenchmark!! With Some Crazy #Number Name!")

      json["name"].should == "DKBenchmark!! With Some Crazy #Number Name!"
    end

    it "should raise an error if the server returns a non 200" do
      expect do
        Vendor::API.meta("WithAnError")
      end.should raise_error(Vendor::API::Error, "Could not complete request. Server returned a status code of 500")
    end

    it "should raise an error if the vendor cannot be found" do
      expect do
        Vendor::API.meta("DoesNotExist")
      end.should raise_error(Vendor::API::Error, "Could not find a valid vendor 'DoesNotExist'")
    end

  end

  context "#download" do

    it "should return a file with the downloaded contents" do
      file = Vendor::API.download("DKBenchmark", "0.1")

      file.should be_kind_of(File)
      File.read(file.path).should == File.read(File.join(PACKAGED_VENDOR_PATH, "DKBenchmark-0.1.vendor"))
    end

    it "should raise an error if the server returns a non 200" do
      expect do
        Vendor::API.download("LibWithError", "0.1")
      end.should raise_error(Vendor::API::Error, "Could not complete request. Server returned a status code of 500")
    end

    it "should raise an error if the vendor cannot be found" do
      expect do
        Vendor::API.download("DKBenchmark", "0.does.not.exist")
      end.should raise_error(Vendor::API::Error, "Could not find a valid version for 'DKBenchmark' that matches '0.does.not.exist'")
    end

  end

end
