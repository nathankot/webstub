describe HTTPStub::Protocol do
  describe ".canInitWithRequest" do
    it "handles all requests" do
      request = NSURLRequest.requestWithURL(NSURL.URLWithString("http://www.yahoo.com/"))

      HTTPStub::Protocol.canInitWithRequest(request).should.be.true
    end
  end
end
