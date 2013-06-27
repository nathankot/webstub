# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), "lib/webstub/version")

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Green"]
  gem.email         = ["mattgreenrocks@gmail.com"]
  gem.description   = "Easily stub out HTTP responses in RubyMotion specs"
  gem.summary       = "Easily stub out HTTP responses in RubyMotion specs"
  gem.homepage      = "https://github.com/mattgreen/webstub"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "webstub"
  gem.require_paths = ["lib"]
  gem.version       = WebStub::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rubygems-tasks"
end
