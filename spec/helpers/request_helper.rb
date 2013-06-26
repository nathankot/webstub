class Response
  def initialize(body, response, error)
    @body = body ? NSString.alloc.initWithData(body, encoding:NSUTF8StringEncoding) : nil
    @headers = response ? response.allHeaderFields : nil
    @error = error
    @status_code = response ? response.statusCode : nil
  end

  attr_reader :body
  attr_reader :headers
  attr_reader :error
  attr_reader :status_code
end

def get(url, headers={})
  request = NSMutableURLRequest.alloc.init
  request.URL = NSURL.URLWithString(url)

  headers.each do |key, value|
    request.setValue(value, forHTTPHeaderField: key.to_s)
  end

  issue_request(request)
end

def post(url, body)
  request = NSMutableURLRequest.alloc.initWithURL(NSURL.URLWithString(url))
  request.HTTPMethod = "POST"

  if body.is_a?(Hash)
    body = body.map do |key, value|
      key = key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      value = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)

      "#{key}=#{value}"
    end.join("&")
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
  end

  request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

  issue_request(request)
end

def issue_request(request)
  result = {}
  queue = NSOperationQueue.alloc.init
  lock = NSConditionLock.alloc.initWithCondition(0)

  NSURLConnection.sendAsynchronousRequest(request,
                                          queue: queue,
                                          completionHandler: lambda do |response, data, error|
                                            lock.lockWhenCondition(0)
                                            result[:data] = data
                                            result[:response] = response
                                            result[:error] = error
                                            lock.unlockWithCondition(1)
                                          end)

  lock.lockWhenCondition(1)

  Response.new(result[:data], result[:response], result[:error])
end
