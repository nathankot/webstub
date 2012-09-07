module HTTPStub
  class Stub
    def initialize(method, path)
      @method = method.to_s.downcase
      @path = path
      @response_body = ""
      @response_headers = {}
    end

    attr_reader :method
    attr_reader :path
    attr_reader :response_body
    attr_reader :response_headers

    def matches?(stub)
      @method == stub.method && @path == stub.path
    end

    def to_return(options)
      @response_body = options[:body] || ""
      @response_headers = options[:headers] || {}

      if content_type = options[:content_type]
        case content_type
        when :json
          content_type = "application/json"
        else
          content_type = content_type.to_s
        end

        @response_headers["Content-Type"] = content_type
      end
    end
  end
end
