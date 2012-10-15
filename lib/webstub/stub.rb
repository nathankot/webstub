module WebStub
  class Stub
    METHODS = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH"].freeze

    def initialize(method, url)
      @request_method = canonicalize_method(method)
      raise ArgumentError, "invalid method name" unless METHODS.include? @request_method
      
      @request_url = canonicalize_url(url)
      @request_headers = nil
      @request_body = nil

      @response_body = ""
      @response_headers = {}
    end

    def matches?(method, url, options={})
      if @request_url != canonicalize_url(url)
        return false
      end

      if @request_method != canonicalize_method(method)
        return false
      end

      if @request_body
        if @request_body != options[:body]
          return false
        end
      end

      true
    end

    attr_reader :response_body
    attr_reader :response_headers
    attr_reader :response_status_code

    def to_return(options)
      @response_status_code = options[:status_code] || 200

      if json = options[:json]
        @response_body = json
        @response_headers["Content-Type"] = "application/json"

        if @response_body.is_a? Hash
          @response_body = JSON.generate(@response_body)
        end
      else
        @response_body = options[:body] || ""
        @response_headers = options[:headers] || {}

        if content_type = options[:content_type]
          @response_headers["Content-Type"] = content_type
        end
      end

      self
    end

    def with(options)
      if body = options[:body]
        @request_body = body

        if @request_body.is_a?(Hash)
          @request_body = @request_body.inject({}) { |h, (k,v)| h[k.to_s] = v; h }
        end
      end

      self
    end

  private

    def canonicalize_method(method)
      method.to_s.upcase
    end

    def canonicalize_url(url)
      url
    end
  end
end
