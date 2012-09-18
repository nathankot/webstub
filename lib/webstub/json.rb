module WebStub
  module JSON
    def self.generate(hash)
      error = Pointer.new(:object)
      result = NSJSONSerialization.dataWithJSONObject(hash, options:0, error:error)

      NSString.alloc.initWithData(result, encoding:NSUTF8StringEncoding)
    end
  end
end
