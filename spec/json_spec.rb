describe WebStub::JSON do
  describe ".generate" do
    it "encodes an empty Array as JSON" do
      WebStub::JSON.generate([]).should == "[]"
    end

    it 'encodes an empty Hash as JSON' do
      WebStub::JSON.generate({}).should == "{}"
    end

    it 'encodes a Hash as JSON' do
      WebStub::JSON.generate({
        int: 42,
        string: "hello",
        array: [1,2,3],
        hash: {
          title: "the title"
        }}).should == "{\"int\":42,\"string\":\"hello\",\"array\":[1,2,3],\"hash\":{\"title\":\"the title\"}}"
    end
  end

  describe ".parse" do
    [:string, :data].each do |type|
      before do
        if type == :string
          @transformer = lambda { |s| s }
        else
          @transformer = lambda { |s| s.dataUsingEncoding(NSUTF8StringEncoding) }
        end
      end

      it "parses an empty Array" do
        WebStub::JSON.parse(@transformer.call("[]")).should == []
      end

      it "parses an empty Hash" do
        WebStub::JSON.parse(@transformer.call("{}")).should == {}
      end

      it "parses a dictionary" do
        json = %q({"int":42,"string":"hello","array":[1,2,3],"hash":{"title":"nested"}})
        WebStub::JSON.parse(@transformer.call(json)).should == {
          "int" => 42, 
          "string" => "hello",
          "array" => [1,2,3],
          "hash" => {"title" => "nested"}
        }
      end
    end
  end
end
