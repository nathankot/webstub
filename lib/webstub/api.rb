module WebStub
  module API
    extend self

    def disable_network_access!
      Protocol.disable_network_access!
    end

    def enable_network_access!
      Protocol.enable_network_access!
    end

    def stub_request(method, path)
      Protocol.add_stub(method, path)
    end

    def reset_stubs
      Protocol.reset_stubs
    end
  end
end
