describe HTTPStub::Protocol do
  before do
    HTTPStub::Protocol.registry.reset!

    @request = NSURLRequest.requestWithURL(NSURL.URLWithString("http://www.google.com/"))
  end

  describe ".canInitWithRequest" do
    describe "when network access is allowed" do
      it "returns false for unstubbed requests" do
        HTTPStub::Protocol.canInitWithRequest(@request).should.be.false
      end

      it "returns true for stubbed requests" do
        HTTPStub::Protocol.registry.add_stub(:get, "http://www.google.com/")
        HTTPStub::Protocol.canInitWithRequest(@request).should.be.true
      end
    end

    describe "when network access is disabled" do
      before do
        HTTPStub::Protocol.disableNetworkAccess
      end

      after do
        HTTPStub::Protocol.enableNetworkAccess
      end

      it "handles all requests" do
        HTTPStub::Protocol.canInitWithRequest(@request).should.be.true
      end
    end
  end

  describe ".disableNetworkAccess" do
    before { HTTPStub::Protocol.disableNetworkAccess }
    after  { HTTPStub::Protocol.enableNetworkAccess }

    it "disables network access" do
      HTTPStub::Protocol.isNetworkAccessAllowed.should.be.false
    end
  end

  describe ".enableNetworkAccess" do
    before do
      HTTPStub::Protocol.disableNetworkAccess
      HTTPStub::Protocol.enableNetworkAccess
    end

    it "enables network access" do
      HTTPStub::Protocol.isNetworkAccessAllowed.should.be.true
    end
  end

  describe ".isNetworkAccessAllowed" do
    describe "by default" do
      it "returns true" do
        HTTPStub::Protocol.isNetworkAccessAllowed.should.be.true
      end
    end

    describe "when network access has been disabled" do
      before { HTTPStub::Protocol.disableNetworkAccess }
      after  { HTTPStub::Protocol.enableNetworkAccess }

      it "returns false" do
        HTTPStub::Protocol.isNetworkAccessAllowed.should.be.false
      end
    end

    describe "when network access has been disabled, then enabled" do
      before do
        HTTPStub::Protocol.disableNetworkAccess
        HTTPStub::Protocol.enableNetworkAccess
      end

      it "returns true" do
        HTTPStub::Protocol.isNetworkAccessAllowed.should.be.true
      end
    end
  end

  describe ".registry" do
    it "stores the stub registry as a singleton" do
      HTTPStub::Protocol.registry.object_id.should == HTTPStub::Protocol.registry.object_id
    end
  end
end
