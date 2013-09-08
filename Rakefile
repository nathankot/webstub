$:.unshift("/Library/RubyMotion/lib")

begin
  if ENV['osx']
    require 'motion/project/template/osx'
  else
    require 'motion/project/template/ios'
  end

rescue LoadError
  require 'motion/project'
end

require 'bundler/setup'

Bundler.setup
Bundler.require

require 'rubygems/tasks'
Gem::Tasks.new

Motion::Project::App.setup do |app|
  gemspec = Dir.glob(File.join(File.dirname(__FILE__), "*.gemspec")).first
  gem_name = File.basename(gemspec).gsub("\.gemspec", "")

  app.development do
    app.files += Dir.glob(File.join(File.dirname(__FILE__), "lib/#{gem_name}/**/*.rb"))

    app.files << File.join(File.dirname(__FILE__), "lib/spec/spec_delegate.rb")
    app.delegate_class = "SpecDelegate"
    app.resources_dirs = %w(spec/resources/images)
  end

  app.name = gem_name
end

