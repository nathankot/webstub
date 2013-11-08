if Kernel.const_defined?(:NSURLSessionConfiguration)
  class NSURLSessionConfiguration
    class << self
      alias_method :originalDefaultSessionConfiguration, :defaultSessionConfiguration

      def self.defaultSessionConfiguration
        config = originalDefaultSessionConfiguration

        unless config.include?(WebStub::Protocol)
          config.protocolClasses << WebStub::Protocol
        end

        config
      end

      alias_method :originalEphemeralSessionConfiguration, :ephemeralSessionConfiguration

      def self.ephemeralSessionConfiguration
        config = originalEphemeralSessionConfiguration

        unless config.include?(WebStub::Protocol)
          config.protocolClasses << WebStub::Protocol
        end

        config
      end
    end
  end
end
