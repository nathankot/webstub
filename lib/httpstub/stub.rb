module HTTPStub
  class Stub
    def initialize(method, path)
      @method = method.to_s.downcase
      @path = path
    end

    attr_reader :method
    attr_reader :path

    def body
      "hello"
    end

    def matches?(stub)
      @method == stub.method && @path == stub.path
    end
  end
end
