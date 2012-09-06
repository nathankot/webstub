module HTTPStub
  def self.stub_request(method, path)
    HTTPStub::Registry.instance.add_stub(method, path)
  end

  def self.register
    NSURLProtocol.registerClass(HTTPStub::Protocol)
  end

  def self.reset!
    HTTPStub::Registry.instance.reset!
  end

  def self.unregister
    NSURLProtocol.unregisterClass(HTTPStub::Protocol)
  end
end
