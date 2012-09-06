module HTTPStub
  class Registry
    def self.instance
      @@instance ||= new()
    end

    def initialize()
      @stubs = []
    end

    def add_stub(method, path)
      @stubs << Stub.new(method, path)
    end

    def get_stub(method, path)
      search = Stub.new(method, path)

      @stubs.each do |stub|
        if stub.matches?(search)
          return stub
        end
      end

      nil
    end

    def reset!
      @stubs = []
    end

    def size
      @stubs.size
    end
  end
end
