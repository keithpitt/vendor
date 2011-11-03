require 'spec_helper'

describe Vendor::Version do

  describe "#bump" do

    it "should incement versions" do
      v("5.2.4").bump.should == v("5.3")
    end

    it "should bump from an alpha" do
      v("5.2.4.a").bump.should == v("5.3")
    end

    it "should bump from an alpha numberic extension" do
      v("5.2.4.a10").bump.should == v("5.3")
    end

    it "should bump with trailing zeros" do
      v("5.0.0").bump.should == v("5.1")
    end

    it "should bump from one level" do
      v("5").bump.should == v("6")
    end

  end

  describe "#create" do

    it "should return itself when passing in a version object" do
      Vendor::Version.create(v("1.0")).should == v("1.0")
    end

    it "should return nil when passing nil" do
      Vendor::Version.create(nil).should be_nil
    end

    it "should allow you to create a version from a string" do
      Vendor::Version.create("5.1").should == v("5.1")
    end

  end

  describe "#==" do

    it "should equal versions if the versions are the same" do
      v("1.2").should == v("1.2")
      v("1.2.b1").should == v("1.2.b.1")
    end

    it "should not equal if the versions are different" do
      v("1.2").should_not == v("1.2.3")
    end

  end

  describe "#eql?" do

    it "should equal versions if the versions are the same" do
      v("1.2").should == v("1.2")
    end

    it "should not equal if the versions are different" do
      v("1.2").eql?(v("1.2.3")).should be_false
      v("1.2.0").eql?(v("1.2")).should be_false
      v("1.2.b1").eql?(v("1.2.b.1")).should be_false
    end

  end

  describe "#initialize" do

    ["1.0", "1.0 ", " 1.0 ", "1.0\n", "\n1.0\n"].each do |good|
      it "should handle different input formats (#{good.inspect})" do
        Vendor::Version.new(good).should == v("1.0")
      end
    end

    it "should handle integers" do
      Vendor::Version.new("1").should == v(1)
    end

    ["junk", "1.0\n2.0"].each do |bad|
      it "should raise argument errors for bad version formats (#{bad.inspect})" do

        expect do
          Vendor::Version.new(bad)
        end.should raise_error(ArgumentError, "Malformed version number string #{bad}")

      end
    end

  end

  describe "#prerelease" do

    it "should return true if the version is a prerelease" do
      v("1.2.0.a").should be_prerelease
      v("2.9.b").should be_prerelease
      v("22.1.50.0.d").should be_prerelease
      v("1.2.d.42").should be_prerelease
      v('1.A').should be_prerelease
    end

    it "should return false if the version is not a prerelease" do
      v("1.2.0").should_not be_prerelease
      v("2.9").should_not be_prerelease
      v("22.1.50.0").should_not be_prerelease
    end

  end

  describe "#release" do

    it "should return the release version" do
      v("1.2.0.a").release.should == v("1.2.0")
      v("1.1.rc10").release.should == v("1.1")
      v("1.9.3.alpha.5").release.should == v("1.9.3")
      v("1.9.3").release.should == v("1.9.3")
    end

  end

  describe "<=>" do

    it "should return the correct value from the spaceship operator" do
      (v("1.0") <=> v("1.0.0")).should == 0
      (v("1.0") <=> v("1.0.a")).should == 1
      (v("1.8.2") <=> v("0.0.0")).should == 1
      (v("1.8.2") <=> v("1.8.2.a")).should == 1
      (v("1.8.2.b") <=> v("1.8.2.a")).should == 1
      (v("1.8.2.a") <=> v("1.8.2")).should == -1
      (v("1.8.2.a10") <=> v("1.8.2.a9")).should == 1
      (v("") <=> v("0")).should == 0

    end

  end

  describe "#spermy_recommendation" do

    it "should return the correct recomendation" do
      v("1").spermy_recommendation.should == "~> 1.0"
      v("1.0").spermy_recommendation.should == "~> 1.0"
      v("1.2").spermy_recommendation.should == "~> 1.2"
      v("1.2.0").spermy_recommendation.should == "~> 1.2"
      v("1.2.3").spermy_recommendation.should == "~> 1.2"
      v("1.2.3.a.4").spermy_recommendation.should == "~> 1.2"
    end

  end

  describe "#to_s" do

    it "should return a string represenation of the version" do
      v("5.2.4").to_s.should == "5.2.4"
    end

  end

  private

    def v(version)
      Vendor::Version.create(version)
    end

end
