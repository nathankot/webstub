gem_name = File.basename(__FILE__).gsub(/\.rb$/, "")

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), gem_name, "**/*.rb")).each do |file|
    app.files.unshift(file)
  end
end
