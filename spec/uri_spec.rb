describe WebStub::URI do
  describe ".decode_www_form" do
    it "decodes a simple form into a Hash" do
      WebStub::URI.decode_www_form("a=42&b=hello").should == { "a" => "42", "b" => "hello" }
    end

    it "unescapes reserved characters properly" do
      WebStub::URI.decode_www_form("comment=hello%2C+my+name+is+%21%40%23%24%25%5E%5E%26*%28%29_-%2B%3D").should ==
        { "comment" => 'hello, my name is !@#$%^^&*()_-+=' }
    end

    it "produces the same Hash, regardless of how components were ordered" do
      WebStub::URI.decode_www_form("a=42&b=hello").should == WebStub::URI.decode_www_form("b=hello&a=42")
    end
  end
end
