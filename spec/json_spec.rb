describe HTTPStub::JSON do
  describe ".generate" do
    it "encodes an empty Array as JSON" do
      HTTPStub::JSON.generate([]).should == "[]"
    end

    it 'encodes an empty Hash as JSON' do
      HTTPStub::JSON.generate({}).should == "{}"
    end

    it 'encodes a Hash as JSON' do
      HTTPStub::JSON.generate({
        int: 42,
        string: "hello",
        array: [1,2,3],
        hash: {
          title: "the title"
        }}).should == "{\"int\":42,\"string\":\"hello\",\"array\":[1,2,3],\"hash\":{\"title\":\"the title\"}}"
    end
  end
end
