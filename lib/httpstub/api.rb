module HTTPStub
  module API
    extend self

    def disable_network_access!
      Protocol.disableNetworkAccess
    end

    def enable_network_access!
      Protocol.enableNetworkAccess
    end

    def stub_request(method, path)
      Protocol.addStub(method, path)
    end

    def reset
      Protocol.resetStubs
    end
  end
end
