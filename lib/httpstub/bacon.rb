# HACK: need define_method to be legal
class Bacon
  class Context
    include HTTPStub::API
  end
end

