require 'spec_helper'

describe Vendor::VendorFile::DependencyGraph do

  let(:graph)             { Vendor::VendorFile::DependencyGraph.new }

  let(:asihttprequest)    { Vendor::VendorFile::Library::Remote.new(:name => "ASIHTTPRequest", :version => "0.5") }
  let(:dksupport)         { Vendor::VendorFile::Library::Local.new(:name => "DKSupport", :version => "0.2") }
  let(:dkapirequest)      { Vendor::VendorFile::Library::Remote.new(:name => "DKAPIRequest", :version => "0.3") }
  let(:dkcoredata)        { Vendor::VendorFile::Library::Git.new(:name => "DKCoreData", :version => "1.5.2") }
  let(:dkrest)            { Vendor::VendorFile::Library::Remote.new(:name => "DKRest", :version => "~> 0.1") }
  let(:versionless_git)   { Vendor::VendorFile::Library::Git.new(:name => "VersionlessGit") }
  let(:versionless_local) { Vendor::VendorFile::Library::Local.new(:name => "VersionlessLocal") }

  let(:dkbenchmark1)      { Vendor::VendorFile::Library::Remote.new(:name => "DKBenchmark", :version => "~> 0.1") }
  let(:dkbenchmark2)      { Vendor::VendorFile::Library::Remote.new(:name => "DKBenchmark", :version => "<= 0.1") }
  let(:dkbenchmark3)      { Vendor::VendorFile::Library::Remote.new(:name => "DKBenchmark", :version => "<= 0.0.1") }

  before :each do
    asihttprequest.parent = dkapirequest
    asihttprequest.stub!(:dependencies).and_return([ dkapirequest, dkbenchmark1 ])
    dksupport.stub!(:dependencies).and_return([ dkapirequest ])
    dkapirequest.stub!(:dependencies).and_return([ asihttprequest, dkbenchmark2 ])
    dkcoredata.stub!(:dependencies).and_return([ dksupport, dkbenchmark3 ])
    dkrest.stub!(:dependencies).and_return([ dksupport, dkapirequest, dkcoredata ])
    versionless_git.stub!(:dependencies).and_return([ ])
    versionless_local.stub!(:dependencies).and_return([ ])
    dkbenchmark1.stub!(:dependencies).and_return([ ])
    dkbenchmark2.stub!(:dependencies).and_return([ ])
    dkbenchmark3.stub!(:dependencies).and_return([ ])
  end

  context 'with a valid graph' do

    before :each do
      graph.libraries = [ dkrest, versionless_local, versionless_git ]
    end

    context "#version_conflicts?" do

      it "should return false" do
        graph.version_conflicts?.should be_false
      end

      it "should poplate the list libraries_to_install property" do
        graph.libraries_to_install.should be_nil
        graph.version_conflicts?

        libraries_to_install = graph.libraries_to_install

        libraries_to_install.first[0].name.should == "ASIHTTPRequest"
        libraries_to_install.first[0].version.should == "0.5"
        libraries_to_install.first[1].should == [ :all ]

        all = libraries_to_install.map { |x| x[0].name }
        all.should == ["ASIHTTPRequest", "DKAPIRequest", "DKBenchmark", "DKCoreData", "DKRest", "DKSupport", "VersionlessGit", "VersionlessLocal"]
      end

    end

    context "#dependency_graph" do

      before :each do
        @graph, @map = graph.dependency_graph
      end

      it "should return a graph" do
        @graph.should == [
          ["DKRest ~> 0.1", [
            ["DKSupport 0.2", [
              ["DKAPIRequest 0.3", [
                ["ASIHTTPRequest 0.5", [
                    ["DKBenchmark ~> 0.1", []]
                  ]
                ],
                ["DKBenchmark <= 0.1", []]
              ]]
            ]],
            ["DKCoreData 1.5.2", [
              ["DKBenchmark <= 0.0.1", []]
            ]]
          ]],
          ["VersionlessLocal", []],
          ["VersionlessGit", []]
        ]
      end

      it "should return a map" do
        @map.keys.sort.should == ["ASIHTTPRequest", "DKAPIRequest", "DKBenchmark", "DKCoreData", "DKRest", "DKSupport", "VersionlessGit", "VersionlessLocal"]
      end

      it "should return each version present in the map" do
        @map["ASIHTTPRequest"].map(&:version).should == [ "0.5" ]
        @map["DKAPIRequest"].map(&:version).should == [ "0.3" ]
        @map["DKCoreData"].map(&:version).should == [ "1.5.2" ]
        @map["DKRest"].map(&:version).should == [ "0.1" ]
        @map["DKSupport"].map(&:version).should == [ "0.2" ]
      end

    end

  end

  context 'with an invalid graph' do

    let(:new_asihttprequest)  { Vendor::VendorFile::Library::Remote.new(:name => "ASIHTTPRequest", :version => "0.6") }

    before :each do
      new_asihttprequest.stub!(:dependencies).and_return([ dkapirequest ])

      graph.libraries = [ dkrest, new_asihttprequest ]
    end

    it "should raise an error and exit" do
      Vendor.ui.should_receive(:error).with("Multiple versions detected for ASIHTTPRequest (0.6, 0.5)").once.ordered
      Vendor.ui.should_receive(:error).with("  ASIHTTPRequest 0.5 is required by DKAPIRequest 0.3").once.ordered
      Vendor.ui.should_receive(:error).with("  ASIHTTPRequest 0.6 is required in the Vendorfile").once.ordered

      expect do
        graph.version_conflicts?
      end.should raise_error(SystemExit)
    end

  end

end
