describe HTTPStub::Registry do
  before do
    @registry = HTTPStub::Registry.new()
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

  describe "#get_stub" do
    describe "when a stub matches" do
      it "returns the stub" do
        @registry.add_stub(:get, "http://www.yahoo.com/")
        @registry.get_stub(:get, "http://www.yahoo.com/").should.not.be.nil
      end
    end

    describe "when no stub matches" do
      it "returns nil" do
        @registry.get_stub(:get, "http://www.google.com/").should.be.nil
      end
    end
  end

  describe "#reset!" do
    it "removes all previously set stubs" do
      @registry.add_stub(:get, "http://www.yahoo.com")
      @registry.reset!
      @registry.size.should == 0
    end
  end
end
