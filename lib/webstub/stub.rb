module WebStub
  class Stub
    METHODS = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH"].freeze

    def initialize(method, url)
      @request_method = canonicalize_method(method)
      raise ArgumentError, "invalid method name" unless METHODS.include? @request_method

      @requests = 0
      
      @request_url = canonicalize_url(url)
      @request_headers = nil
      @request_body = nil

      @response_body = ""
      @response_delay = 0.0
      @response_error = nil
      @response_headers = {}
      @response_status_code = 200
    end

    def error?
      ! @response_error.nil?
    end

    def matches?(method, url, options={})
      if @request_url != canonicalize_url(url)
        return false
      end

      if @request_method != canonicalize_method(method)
        return false
      end

      if @request_headers
        headers = options[:headers] || {}

        @request_headers.each do |key, value|
          if headers[key] != value
            return false
          end
        end
      end

      if @request_body
        if @request_body != options[:body]
          return false
        end
      end

      true
    end

    attr_accessor :requests

    def redirects?
      @response_status_code.between?(300, 399) && @response_headers["Location"] != nil
    end

    def requested?
      @requests > 0
    end

    attr_reader :response_body
    attr_reader :response_delay
    attr_reader :response_error
    attr_reader :response_headers
    attr_reader :response_status_code

    def to_fail(options)
      if error = options.delete(:error)
        @response_error = error
      elsif code = options.delete(:code)
        @response_error = NSError.errorWithDomain(NSURLErrorDomain, code: code, userInfo: nil)
      else
        raise ArgumentError, "to_fail requires either the code or error option" 
      end

      self
    end

    def to_return(options)
      if status_code = options[:status_code]
        @response_status_code = status_code
      end

      if headers = options[:headers]
        @response_headers.merge!(headers)
      end

      if json = options[:json]
        @response_body = json
        @response_headers["Content-Type"] = "application/json"

        if @response_body.is_a?(Hash) || @response_body.is_a?(Array)
          @response_body = JSON.generate(@response_body)
        end
      else
        @response_body = options[:body] || ""

        if content_type = options[:content_type]
          @response_headers["Content-Type"] = content_type
        end
      end

      if delay = options[:delay]
        @response_delay = delay
      end

      self
    end

    def to_redirect(options)
      unless url = options.delete(:url)
        raise ArgumentError, "to_redirect requires the :url option"
      end

      options[:headers] ||= {}
      options[:headers]["Location"] = url
      options[:status_code] = 301

      to_return(options)
    end

    def with(options)
      if body = options[:body]
        @request_body = body

        if @request_body.is_a?(Hash)
          @request_body = @request_body.inject({}) { |h, (k,v)| h[k.to_s] = v; h }
        end
      end

      if headers = options[:headers]
        @request_headers = headers
      end

      self
    end

  private

    def canonicalize_method(method)
      method.to_s.upcase
    end

    def canonicalize_url(url)
      scheme, authority, hostname, port, path, query, fragment = URI.split(url)

      parts = scheme.downcase
      parts << "://"

      if authority
        parts << authority
        parts << "@"
      end

      parts << hostname.downcase

      if port
        well_known_ports = { "http" => 80, "https" => 443 }
        if well_known_ports[scheme] != port
          parts << ":#{port}"
        end
      end

      if path != "/"
        parts << path
      end

      if query
        parts << "?#{query}"
      end

      if fragment
        parts << "##{fragment}"
      end

      parts
    end
  end
end
