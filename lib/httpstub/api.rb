module HTTPStub
  module API
    def self.disable_network_access!
      Protocol.disableNetworkAccess
    end

    def self.enable_network_access!
      Protocol.enableNetworkAccess
    end

    def self.stub_request(method, path)
      Protocol.registry.add_stub(method, path)
    end

    def self.reset!
      Protocol.registry.reset!
    end
  end
end
