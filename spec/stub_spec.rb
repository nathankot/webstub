describe HTTPStub::Stub do
  before do
    @stub = HTTPStub::Stub.new(:get, "http://www.yahoo.com/")
  end

  it "holds the method and the path" do
    @stub.should.not.be.nil
  end

  describe "#matches?" do
    it "returns true when provided an identical stub" do
      @stub.matches?(@stub.dup).should.be.true
    end

    it "returns false when the URL differs" do
      @stub.matches?(HTTPStub::Stub.new(:get, "http://www.google.com/")).should.be.false
    end

    it "returns false when the method differs" do
      @stub.matches?(HTTPStub::Stub.new(:post, "http://www.yahoo.com/")).should.be.false
    end
  end

  describe "#response_body" do
    it "returns the response body" do
      @stub.response_body.should == "" 
    end
  end

  describe "#to_return" do
    it "sets the response" do
      @stub.to_return(body: "hello")
      @stub.response_body.should.be == "hello"
    end
  end
end
