module WebStub
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

    def self.split(str)
      url = NSURL.URLWithString(str)

      scheme = url.scheme
      user = url.user
      password = url.password
      hostname = url.host
      port = url.port
      path = url.path
      query = url.query
      fragment = url.fragment

      user_info = nil
      if user || password
        user_info = "#{user}:#{password}"
      end

      [scheme, user_info, hostname, port, path, query, fragment]
    end
  end
end
