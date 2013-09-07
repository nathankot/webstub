module WebStub
  class Protocol < NSURLProtocol
    def self.add_stub(*args)
      registry.add_stub(*args)
    end

    def self.canInitWithRequest(request)
      return false unless spec_mode?
      return false unless supported?(request)

      if stub_for(request)
        return true
      end

      ! network_access_allowed?
    end

    def self.canonicalRequestForRequest(request)
      request
    end

    def self.disable_network_access!
      @network_access = false
    end

    def self.enable_network_access!
      @network_access = true
    end

    def self.network_access_allowed?
      @network_access.nil? ? true : @network_access
    end

    def self.reset_stubs
      registry.reset
    end

    def initWithRequest(request, cachedResponse:response, client: client)
      if super
        @stub = nil
        @timer = nil
      end

      self
    end

    def completeLoading
      response = NSHTTPURLResponse.alloc.initWithURL(request.URL,
                                                     statusCode:@stub.response_status_code,
                                                     HTTPVersion:"HTTP/1.1",
                                                     headerFields:@stub.response_headers)
      @stub.requests += 1

      if @stub.error?
        client.URLProtocol(self, didFailWithError: @stub.response_error)
        return
      end

      if @stub.redirects?
        url = NSURL.URLWithString(@stub.response_headers["Location"])
        redirect_request = NSURLRequest.requestWithURL(url)

        client.URLProtocol(self, wasRedirectedToRequest: redirect_request, redirectResponse: response)

        unless @stub = self.class.stub_for(redirect_request)
          error = NSError.errorWithDomain("WebStub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
          client.URLProtocol(self, didFailWithError:error)

          return
        end

        @timer = NSTimer.scheduledTimerWithTimeInterval(@stub.response_delay, target:self, selector: :completeLoading, userInfo:nil, repeats:false)
        return
      end

      client.URLProtocol(self, didReceiveResponse:response, cacheStoragePolicy:NSURLCacheStorageNotAllowed)
      client.URLProtocol(self, didLoadData: @stub.response_body.is_a?(NSData) ? @stub.response_body :
                         @stub.response_body.dataUsingEncoding(NSUTF8StringEncoding))
      client.URLProtocolDidFinishLoading(self)
    end

    def startLoading
      request = self.request
      client = self.client
    
      unless @stub = self.class.stub_for(self.request)
        error = NSError.errorWithDomain("WebStub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
        client.URLProtocol(self, didFailWithError:error)

        return
      end

      @timer = NSTimer.scheduledTimerWithTimeInterval(@stub.response_delay, target:self, selector: :completeLoading, userInfo:nil, repeats:false)
    end

    def stopLoading
      if @timer
        @timer.invalidate
      end
    end

  private

    def self.registry
      @registry ||= Registry.new()
    end

    def self.stub_for(request)
      options = { headers: request.allHTTPHeaderFields }
      if body = parse_body(request)
        options[:body] = body
      end

      registry.stub_matching(request.HTTPMethod, request.URL.absoluteString, options)
    end

    def self.parse_body(request)
      return nil unless request.HTTPBody

      content_type = nil

      request.allHTTPHeaderFields.each do |key, value|
        if key.downcase == "content-type"
          content_type = value
          break
        end
      end

      body = NSString.alloc.initWithData(request.HTTPBody, encoding:NSUTF8StringEncoding)
      return nil unless body

      case content_type
      when /application\/x-www-form-urlencoded/
        URI.decode_www_form(body)
      else
        body
      end
    end

    def self.spec_mode?
      RUBYMOTION_ENV == 'test'
    end

    def self.supported?(request)
      return false unless request.URL
      return false unless request.URL.scheme.start_with?("http")

      true
    end
  end
end
