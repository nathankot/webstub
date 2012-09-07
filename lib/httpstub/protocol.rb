module HTTPStub
  class Protocol < NSURLProtocol
    def self.canInitWithRequest(request)
      if registry.get_stub(request.HTTPMethod, request.URL.absoluteString)
        return true
      end

      ! isNetworkAccessAllowed
    end

    def self.canonicalRequestForRequest(request)
      request
    end

    def self.disableNetworkAccess
      @network_access = false
    end

    def self.enableNetworkAccess
      @network_access = true
    end

    def self.isNetworkAccessAllowed
      @network_access.nil? ? true : @network_access
    end

    def self.registry
      @registry ||= Registry.new()
    end

    def startLoading
      request = self.request
      client = self.client
      
      stub = self.class.registry.get_stub(request.HTTPMethod, request.URL.absoluteString)
      unless stub
        error = NSError.errorWithDomain("httpstub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
        client.URLProtocol(self, didFailWithError:error)

        return
      end

      response = NSHTTPURLResponse.alloc.initWithURL(request.URL,
                                                     statusCode:200,
                                                     HTTPVersion:"HTTP/1.1",
                                                     headerFields:stub.response_headers)

      client.URLProtocol(self, didReceiveResponse:response, cacheStoragePolicy:NSURLCacheStorageNotAllowed)
      client.URLProtocol(self, didLoadData:stub.response_body.dataUsingEncoding(NSUTF8StringEncoding))
      client.URLProtocolDidFinishLoading(self)
    end

    def stopLoading
    end
  end
end

NSURLProtocol.registerClass(HTTPStub::Protocol)
