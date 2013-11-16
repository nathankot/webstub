if Kernel.const_defined?(:NSURLSessionConfiguration)
  class NSURLSessionConfiguration
    class << self
      alias_method :originalDefaultSessionConfiguration, :defaultSessionConfiguration

      def defaultSessionConfiguration
        config = originalDefaultSessionConfiguration

        protocols = config.protocolClasses || []
        unless protocols.include?(WebStub::Protocol)
          protocols << WebStub::Protocol
          config.protocolClasses = protocols
        end

        config
      end

      alias_method :originalEphemeralSessionConfiguration, :ephemeralSessionConfiguration

      def ephemeralSessionConfiguration
        config = originalEphemeralSessionConfiguration

        protocols = config.protocolClasses || []
        unless protocols.include?(WebStub::Protocol)
          protocols << WebStub::Protocol
          config.protocolClasses = protocols
        end

        config
      end
    end
  end
end
