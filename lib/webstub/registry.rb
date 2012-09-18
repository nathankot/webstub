module WebStub
  class Registry
    def initialize()
      @stubs = []
    end

    def add_stub(method, path)
      stub = Stub.new(method, path)
      @stubs << stub

      stub
    end

    def reset
      @stubs = []
    end

    def size
      @stubs.size
    end
    
    def stub_matching(method, url, options={})
      @stubs.each do |stub|
        if stub.matches?(method, url, options)
          return stub
        end
      end

      nil
    end
  end
end
