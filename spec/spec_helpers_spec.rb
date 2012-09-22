describe WebStub::SpecHelpers do
  extend WebStub::SpecHelpers

  it "includes WebStub::API" do
    self.class.ancestors.should.include? WebStub::API
  end

  it "calls reset_stubs in an after block" do
    self.instance_variable_get(:@after).should.not.be.empty
  end
end
