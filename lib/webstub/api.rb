module WebStub
  module API
    extend self

    def disable_network_access!
      protocol.disable_network_access!
    end

    def enable_network_access!
      protocol.enable_network_access!
    end

    def stub_request(method, path)
      protocol.add_stub(method, path)
    end

    def reset_stubs
      protocol.reset_stubs
    end

    private

    def protocol
      Dispatch.once { NSURLProtocol.registerClass(WebStub::Protocol) }

      Protocol
    end
  end
end
