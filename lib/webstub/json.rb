module WebStub
  module JSON
    def self.generate(hash)
      error = Pointer.new(:object)
      result = NSJSONSerialization.dataWithJSONObject(hash, options:0, error:error)

      NSString.alloc.initWithData(result, encoding:NSUTF8StringEncoding)
    end

    def self.parse(str)
      data = str
      unless data.is_a?(NSData)
        data = str.dataUsingEncoding(NSUTF8StringEncoding)
      end

      error = Pointer.new(:object)
      result = NSJSONSerialization.JSONObjectWithData(data, options: 0, error: error)

      result
    end
  end
end
