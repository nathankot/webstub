describe WebStub::API do
  before do
    WebStub::API.reset_stubs
    
    @url = "http://www.example.com/"
    @request = NSURLRequest.requestWithURL(NSURL.URLWithString(@url))
  end

  describe ".stub_request" do
    it "returns the newly added stub" do
      WebStub::API.stub_request(:get, @url).should.not.be.nil
    end
    
    before { WebStub::API.disable_network_access! }
    after  { WebStub::API.enable_network_access! }

    describe "when a request does not match any previously set stubs" do
      describe "when no body is set" do
        before do
          @response = get @url
        end

        it "returns a nil body" do
          @response.body.should.be.nil
        end

        it "returns an error with a description of the problem" do
          @response.error.localizedDescription.should.not.be.empty
        end
      end

      describe "when a body is set" do
        before do
          WebStub::API.stub_request(:post, @url).
            with(body: { :q => "hi" })

          @response = post @url, :q => "hello"
        end

        it "requires the request body to match" do
          @response.body.should.be.nil
        end
      end

      describe "when a header is set" do
        before do
          WebStub::API.stub_request(:get, @url).
            with(headers: { "Header" => "Value" })

          @response = get(@url)
        end

        it "requires the header to be present" do
          @response.error.should.not.be.nil
        end
      end
    end

    describe "when a request matches a stub" do
      describe "and the request does include a body" do
        before do
          @stub = WebStub::API.stub_request(:get, @url).to_return(body:"hello", headers: {"Content-Type" => "text/plain"})

          @response = get @url
        end

        it "has the content-type header" do
          @response.headers["Content-Type"].should == "text/plain"
        end

        it "returns a non-nil body" do
          @response.body.length.should.be == 5
        end

        it "returns a nil error" do
          @response.error.should.be.nil
        end

        it "returns a 200 status code" do
          @response.status_code.should.be == 200
        end

        it "marks the stub as requested" do
          @stub.should.be.requested
        end
      end

      describe "and the request includes a body" do
        describe "of form data" do
          before do
            WebStub::API.stub_request(:post, @url).
              with(body: { q: "search" }).
              to_return(json: { results: ["result 1", "result 2"] })

            @response = post @url, :q => "search"
          end

          it "returns the correct body" do
            @response.body.should == '{"results":["result 1","result 2"]}'
          end
        end
      end

      describe "with raw data" do
        before do
          WebStub::API.stub_request(:post, @url).
            with(body: "raw body").
            to_return(json: { results: ["result 1", "result 2"] })

          @response = post @url, "raw body"
        end

        it "returns the correct body" do
          @response.body.should == '{"results":["result 1","result 2"]}'
        end
      end
    end

    describe "response with binary data" do
      before do
        @image = load_image('homer')
        @url = 'http://somehost/image'
        WebStub::API.stub_request(:get, @url).
          to_return(body: load_image('homer'), content_type: "image/jpeg")
      end

      it "returns the correct body" do
        @response = get(@url, :binary_resp)
        @response.body.isEqualToData(@image).should == true
      end
    end


    describe "when a stub sets a specified status code" do
      before do
        WebStub::API.stub_request(:get, @url).
          to_return(json: {error: "Not Found"}, status_code: 400)

        @response = get @url
      end

      it "the status code of the response should match" do
        @response.status_code.should.be == 400
      end
    end

    describe "when a stub sets a delay" do
      before do
        WebStub::API.stub_request(:get, @url).
          to_return(json: {}, delay: 1.0)
      end

      it "returns a response after the specified amount of time" do
        start = Time.now
        get @url
        finish = Time.now

        (finish - start).should.be >= 1.0
      end
    end

    describe "when a stub requires a header" do
      before do
        WebStub::API.stub_request(:get, @url).
          with(headers: { "My-Header" => "123" }).
          to_return(json: {})
      end

      it "returns the correct body" do
        response = get(@url, :string_resp, { "My-Header" => "123" })

        response.body.should == '{}'
      end
    end

    describe "when a stub redirects" do
      it "redirects the request" do
        @redirect_url = @url + "redirect"

        WebStub::API.stub_request(:get, @url).
          to_redirect(url: @redirect_url)
        WebStub::API.stub_request(:get, @redirect_url).
          to_return(json: {})

        response = get(@url)

        response.body.should == '{}'
      end
    end

    describe "when a stub is configured to fail" do
      it "fails the request" do
        WebStub::API.stub_request(:get, @url).
          to_fail(code: NSURLErrorNetworkConnectionLost)

        response = get(@url)

        response.error.code.should == NSURLErrorNetworkConnectionLost
      end
    end
  end

  describe ".reset_stubs" do
    before do
      WebStub::API.stub_request(:get, @url)
      WebStub::API.reset_stubs
    end

    describe "when network access is disabled" do
      before do
        WebStub::API.disable_network_access!

        @response = get @url
      end

      after do
        WebStub::API.enable_network_access!
      end

      it "returns a nil body" do
        @response.body.should.be.nil
      end

      it "returns an error with a description of the problem" do
        @response.error.localizedDescription.should.not.be.empty
      end
    end

    describe "when network access is enabled" do
      before do
        @response = get @url
      end

      it "returns a non-nil body" do
        @response.body.length.should.be > 100
      end

      it "returns a nil error" do
        @response.error.should.be.nil
      end
    end
  end
end
