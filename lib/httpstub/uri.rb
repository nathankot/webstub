module HTTPStub
  module URI
    def self.decode_www_form(str)
      str.split("&").inject({}) do |hash, component|
        key, value = component.split("=", 2)
        hash[decode_www_form_component(key)] = decode_www_form_component(value)

        hash
      end
    end

    def self.decode_www_form_component(str)
      str.gsub("+", " ").stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    end
  end
end
