require 'spec_helper'

describe Vendor::CLI::Auth do

  context "#is_authenticated?" do

    it "should return false if no api key is set" do
      Vendor::CLI::Auth.api_key = nil

      Vendor::CLI::Auth.is_authenticated?.should be_false
    end

    it "should return true if an api key is set" do
      Vendor::CLI::Auth.api_key = "secret"

      Vendor::CLI::Auth.is_authenticated?.should be_true
    end

  end

  context "#with_api_key" do

    it "should ask for credentials credentials before running the block if they're not authenticated" do
      Vendor::CLI::Auth.api_key = nil
      Vendor::CLI::Auth.should_receive :fetch_api_key

      Vendor::CLI::Auth.with_api_key { |api_key| }
    end

    it "should run the block with the API key if one exists" do
      Vendor::CLI::Auth.api_key = "secret"
      Vendor::CLI::Auth.should_not_receive :fetch_api_key

      Vendor::CLI::Auth.with_api_key do |api_key|
        api_key.should == "secret"
      end
    end

  end

  context "#fetch_api_key" do

    it "should ask for their username and password" do
      STDIN.should_receive(:gets).once.ordered.and_return "keithpitt"
      STDIN.should_receive(:gets).once.ordered.and_return "password"
      Vendor.ui.should_receive(:warn).once
      Vendor::CLI::Auth.should_receive(:printf).twice

      Vendor::CLI::Auth.fetch_api_key.should == "secret"
    end

  end

end
