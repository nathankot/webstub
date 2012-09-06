describe HTTPStub do
  before do
    @url = "http://www.google.com/"
    @request = NSURLRequest.requestWithURL(NSURL.URLWithString(@url))
  end

  describe ".register" do
    before do
      HTTPStub.register()
    end

    after do
      HTTPStub.unregister()
    end

    describe "when a request does not match any previously set stubs" do
      before do
        @response = Pointer.new(:object)
        @error = Pointer.new(:object) 
        @body = NSURLConnection.sendSynchronousRequest(@request, returningResponse:@response, error:@error)
      end

      it "returns a nil response" do
        @response[0].should.be.nil
      end

      it "returns a nil body" do
        @body.should.be.nil
      end

      it "returns an error with a description of the problem" do
        @error[0].localizedDescription.should.not.be.empty
      end
    end

    describe "when a request matches a previously set stub" do
      before do
        HTTPStub.stub_request(:get, @url).to_return(body:"hello", headers: {"Content-Type" => "text/plain"})

        @response = Pointer.new(:object)
        @error = Pointer.new(:object) 
        @body = NSURLConnection.sendSynchronousRequest(@request, returningResponse:@response, error:@error)
      end

      it "returns a non-nil response" do
        @response[0].should.not.be.nil
      end

      it "has the content-type header" do
        @response[0].allHeaderFields["Content-Type"].should == "text/plain"
      end

      it "returns a non-nil body" do
        @body.length.should.be == 5
      end

      it "returns a nil error" do
        @error[0].should.be.nil
      end
    end
  end

  describe ".reset!" do
    before do
      HTTPStub.register()
      HTTPStub.stub_request(:get, @url)
      HTTPStub.reset!

      @response = Pointer.new(:object)
      @error = Pointer.new(:object) 
      @body = NSURLConnection.sendSynchronousRequest(@request, returningResponse:@response, error:@error)
    end

    after do
      HTTPStub.unregister()
    end

    it "returns a nil response" do
      @response[0].should.be.nil
    end

    it "returns a nil body" do
      @body.should.be.nil
    end

    it "returns an error with a description of the problem" do
      @error[0].localizedDescription.should.not.be.empty
    end
  end

  describe ".stub_request" do
    it "returns the newly added stub" do
      HTTPStub.stub_request(:get, @url).should.not.be.nil
    end
  end

  describe ".unregister" do
    before do
      HTTPStub.register()
      HTTPStub.stub_request(:get, @url)
      HTTPStub.unregister()

      @response = Pointer.new(:object)
      @error = Pointer.new(:object) 
      @body = NSURLConnection.sendSynchronousRequest(@request, returningResponse:@response, error:@error)
    end

    it "returns a valid response" do
      @response[0].statusCode.should.be < 400
    end

    it "returns the body" do
      @body.length.should.be > 500
    end

    it "returns a nil error" do
      @error[0].should.be.nil
    end
  end  
end
