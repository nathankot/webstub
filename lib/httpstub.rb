if defined?(Motion::Project::Config)
  gem_name = File.basename(__FILE__).gsub(".rb$", "")

  Motion::Project::App.setup do |app|
    Dir.glob(File.expand_path(File.join(gem_name, "**/*.rb"), __FILE__)).each do |file|
      app.files.unshift(file)
    end
  end
end

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
