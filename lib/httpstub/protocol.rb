module HTTPStub
  class Protocol < NSURLProtocol
    def self.canInitWithRequest(request)
      ! request.nil?
    end

    def self.canonicalRequestForRequest(request)
      request
    end

    def startLoading
      request = self.request
      client = self.client
      
      stub = HTTPStub::Registry.instance.get_stub(request.HTTPMethod, request.URL.absoluteString)
      unless stub
        error = NSError.errorWithDomain("httpstub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
        client.URLProtocol(self, didFailWithError:error)

        return
      end

      response = NSHTTPURLResponse.alloc.initWithURL(request.URL, statusCode:200, HTTPVersion:"HTTP/1.1", headerFields:{})

      client.URLProtocol(self, didReceiveResponse:response, cacheStoragePolicy:NSURLCacheStorageNotAllowed)
      client.URLProtocol(self, didLoadData:stub.body)
      client.URLProtocolDidFinishLoading(self)
    end

    def stopLoading
    end
  end
end
