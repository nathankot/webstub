module HTTPStub
  class Stub
    def initialize(method, path)
      @method = method.to_s.downcase
      @path = path
      @response_body = ""
    end

    attr_reader :method
    attr_reader :path
    attr_reader :response_body

    def matches?(stub)
      @method == stub.method && @path == stub.path
    end

    def to_return(options)
      @response_body = options[:body] || ""
    end
  end
end
