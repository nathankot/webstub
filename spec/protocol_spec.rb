describe WebStub::Protocol do
  before do
    WebStub::Protocol.reset_stubs

    @request = NSURLRequest.requestWithURL(NSURL.URLWithString("http://www.google.com/"))
  end

  describe ".canInitWithRequest" do
    describe "when network access is allowed" do
      it "returns false for unstubbed requests" do
        WebStub::Protocol.canInitWithRequest(@request).should.be.false
      end

      it "returns true for stubbed requests" do
        WebStub::Protocol.add_stub(:get, "http://www.google.com/")
        WebStub::Protocol.canInitWithRequest(@request).should.be.true
      end
    end

    describe "when network access is disabled" do
      before { WebStub::Protocol.disable_network_access! }
      after  { WebStub::Protocol.enable_network_access! }

      it "handles all requests" do
        WebStub::Protocol.canInitWithRequest(@request).should.be.true
      end
    end
  end

  describe ".disable_network_access!" do
    before { WebStub::Protocol.disable_network_access! }
    after  { WebStub::Protocol.enable_network_access! }

    it "disables network access" do
      WebStub::Protocol.network_access_allowed?.should.be.false
    end
  end

  describe ".enable_network_access!" do
    before do
      WebStub::Protocol.disable_network_access!
      WebStub::Protocol.enable_network_access!
    end

    it "enables network access" do
      WebStub::Protocol.network_access_allowed?.should.be.true
    end
  end

  describe ".isNetworkAccessAllowed" do
    describe "by default" do
      it "returns true" do
        WebStub::Protocol.network_access_allowed?.should.be.true
      end
    end

    describe "when network access has been disabled" do
      before { WebStub::Protocol.disable_network_access! }
      after  { WebStub::Protocol.enable_network_access! }

      it "returns false" do
        WebStub::Protocol.network_access_allowed?.should.be.false
      end
    end

    describe "when network access has been disabled, then enabled" do
      before do
        WebStub::Protocol.disable_network_access!
        WebStub::Protocol.enable_network_access!
      end

      it "returns true" do
        WebStub::Protocol.network_access_allowed?.should.be.true
      end
    end
  end

  describe ".registry" do
    it "stores the stub registry as a singleton" do
      WebStub::Protocol.registry.object_id.should == WebStub::Protocol.registry.object_id
    end
  end
end
