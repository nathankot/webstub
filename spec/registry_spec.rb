describe WebStub::Registry do
  before do
    @registry = WebStub::Registry.new()
  end

  it "has no requests initially" do
    @registry.size.should == 0
  end

  describe "#add_stub" do
    it "inserts a stub" do
      @registry.add_stub(:get, "http://www.yahoo.com/")
      @registry.size.should == 1
    end
  end

  describe "#reset" do
    it "removes all previously set stubs" do
      @registry.add_stub(:get, "http://www.yahoo.com")
      @registry.reset
      @registry.size.should == 0
    end
  end
end
