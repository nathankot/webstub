module WebStub
  module SpecHelpers
    def self.extended(base)
      base.class.send(:include, WebStub::API)

      base.after { reset_stubs }
    end
  end
end
