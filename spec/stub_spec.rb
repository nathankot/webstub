describe WebStub::Stub do
  before do
    @stub = WebStub::Stub.new(:get, "http://www.yahoo.com/")
  end

  it "holds the method and the path" do
    @stub.should.not.be.nil
  end

  it "allows all valid HTTP methods" do
    WebStub::Stub::METHODS.each do |method|
      lambda { WebStub::Stub.new(method, "http://www.yahoo.com/") }.should.not.raise(ArgumentError)
    end
  end

  it "does not allow invalid HTTP methods" do
    lambda { WebStub::Stub.new("invalid", "http://www.yahoo.com/") }.should.raise(ArgumentError)
  end

  describe "#matches?" do
    it "returns true when provided an identical stub" do
      @stub.matches?(:get, "http://www.yahoo.com/").should.be.true
    end

    it "returns false when the URL differs" do
      @stub.matches?(:get, "http://www.google.com/").should.be.false
    end

    it "returns false when the method differs" do
      @stub.matches?(:post, "http://www.yahoo.com/").should.be.false
    end

    describe "body" do
      describe "with a dictionary" do
        before do
          @stub = WebStub::Stub.new(:post, "http://www.yahoo.com/search").
            with(body: { :q => "query"})
        end

        it "returns false when the body does not match" do
          @stub.matches?(:post, "http://www.yahoo.com/search", { :body => {}}).should.be.false          
        end

        it "returns true when the body matches (with string keys)" do
          @stub.matches?(:post, "http://www.yahoo.com/search", { :body => { "q" => "query" }}).should.be.true
        end
      end

      describe "with a string" do
        before do
          @stub = WebStub::Stub.new(:post, "http://www.yahoo.com/search").
            with(body: "raw body")
        end

        it "returns true when an identical body is provided" do
          @stub.matches?(:post, "http://www.yahoo.com/search", { :body => "raw body" }).should.be.true
        end

        it "returns false when a dictionary is provided" do
          @stub.matches?(:post, "http://www.yahoo.com/search", { :body => { "q" => "query" }}).should.be.false
        end

        it "returns false without a body" do
          @stub.matches?(:post, "http://www.yahoo.com/search").should.be.false
        end
      end
    end
  end

  describe "#response_body" do
    it "returns the response body" do
      @stub.response_body.should == "" 
    end
  end

  describe "#to_return" do
    it "sets the response body" do
      @stub.to_return(body: "hello")
      @stub.response_body.should.be == "hello"
    end

    it "allows JSON results by passing :json with a string" do
      @stub.to_return(json: '{"value":42}')
      @stub.response_headers["Content-Type"].should == "application/json"
      @stub.response_body.should == '{"value":42}'
    end

    it "allows JSON results by passing :json with a hash" do
      @stub.to_return(json: {:value => 42})
      @stub.response_headers["Content-Type"].should == "application/json"
      @stub.response_body.should == '{"value":42}'
    end

    it "sets response headers" do
      @stub.to_return(body: "{}", headers: { "Content-Type" => "application/json" })
      @stub.response_headers.should.be == { "Content-Type" => "application/json" } 
    end

    it "sets the response status code" do
      @stub.to_return(body: "{}", status_code: 400)
      @stub.response_status_code.should.be == 400
    end
  end
end
