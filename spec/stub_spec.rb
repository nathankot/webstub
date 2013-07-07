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

  it "does not have a response error by default" do
    @stub.response_error.should.be.nil
  end

  describe "#error?" do
    describe "by default" do
      it "returns false" do
        @stub.error?.should.be.false
      end
    end

    describe "after calling to_fail" do
      it "returns true" do
        @stub.to_fail(code: NSURLErrorUnsupportedURL)

        @stub.error?.should.be.true
      end
    end
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

    describe "canonicalizing URLs" do
      it "lowercases the scheme" do
        @stub.matches?(:get, "HTTP://www.yahoo.com/").should.be.true
      end

      it "lowercases the hostname" do
        @stub.matches?(:get, "http://WWW.YAHOo.COM/").should.be.true
      end

      it "ignores default HTTP port" do
        @stub.matches?(:get, "http://www.yahoo.com:80/").should.be.true
      end

      it "ignores default HTTPS port" do
        stub = WebStub::Stub.new(:get, "https://www.yahoo.com/")

        stub.matches?(:get, "https://www.yahoo.com:443/").should.be.true
      end

      it "ignores a path with \"/\"" do
        @stub.matches?(:get, "http://www.yahoo.com:80/").should.be.true
      end
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

    describe "headers" do
      before do
        @stub = WebStub::Stub.new(:get, "http://www.yahoo.com/search").
          with(headers: { "Authorization" => "secret" })
      end

      it "returns true when the headers are included" do
        @stub.matches?(:get, "http://www.yahoo.com/search", 
                       headers: { "X-Extra" => "42", "Authorization" => "secret" }).should.be.true
      end

      it "returns false when any of the headers are absent" do
        @stub.matches?(:get, "http://www.yahoo.com/search", 
                       headers: { "X-Extra" => "42" }).should.be.false
      end
    end
  end

  describe "#requested?" do
    describe "by default" do
      it "returns false" do
        @stub.should.not.be.requested
      end
    end

    describe "after incrementing the request count" do
      before do
        @stub.requests += 1
      end

      it "returns true" do
        @stub.should.be.requested
      end
    end
  end

  describe "#response_body" do
    it "returns the response body" do
      @stub.response_body.should == "" 
    end
  end

  describe "#to_fail" do
    it "rejects an empty options Hash" do
      lambda { @stub.to_fail({}) }.should.raise(ArgumentError)
    end

    it "builds an NSError using the option specified by code" do
      @stub.to_fail(code: NSURLErrorUnsupportedURL)

      @stub.response_error.domain.should == NSURLErrorDomain
      @stub.response_error.code.should == NSURLErrorUnsupportedURL
    end

    it "accepts an arbitrary NSError using the error option" do
      error = NSError.errorWithDomain(0, code: 123, userInfo: nil)
      @stub.to_fail(error: error)

      @stub.response_error.should == error
    end

    it "returns self" do
      @stub.to_fail(code: 123).should == @stub
    end
  end

  describe "#to_redirect" do
    it "requires the :url option" do
      lambda { @stub.to_redirect }.should.raise(ArgumentError)
    end

    it "sets the Location header to the specified URL" do
      @stub.to_redirect(url: "http://example.org/")

      @stub.response_headers.should.include("Location")
    end

    it "sets the status code to 301" do
      @stub.to_redirect(url: "http://example.org/")

      @stub.response_status_code.should == 301
    end

    it "returns the stub" do
      @stub.to_redirect(url: "http://example.org/").should == @stub
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

    it "allows JSON results by passing :json with an array" do
      @stub.to_return(json: [{:value => 42}])
      @stub.response_headers["Content-Type"].should == "application/json"
      @stub.response_body.should == '[{"value":42}]'
    end

    it "sets a delay time" do
      @stub.to_return(body: "{}", delay: 0.5)
      @stub.response_delay.should == 0.5
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
