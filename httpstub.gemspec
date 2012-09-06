# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), "lib/httpstub/version")

Gem::Specification.new do |gem|
  gem.authors       = ["AUTHOR"]
  gem.email         = ["EMAIL"]
  gem.description   = "DESCRIPTION"
  gem.summary       = "SUMMARY"
  gem.homepage      = "URL"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "httpstub"
  gem.require_paths = ["lib"]
  gem.version       = HTTPStub::VERSION
end
