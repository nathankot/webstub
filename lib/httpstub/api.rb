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
      Protocol.registry.add_stub(method, path)
    end

    def reset!
      Protocol.registry.reset!
    end
  end
end

=begin
# TODO: remove once define_method is allowed
class Bacon
  class Context
    include HTTPStub::API
  end
end
=end
