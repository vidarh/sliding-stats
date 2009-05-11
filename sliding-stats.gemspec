
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
 
  s.name = 'sliding-stats'
  s.version = '0.2.7'
  s.date = '2009-03-06'
 
  s.description = "Rack Middleware to provide a 'sliding view' over the last N requests to your web app"
  s.summary = s.description
 
  s.authors = ["vidarh"]
  s.email = "vidar@hokstad.com"
 
  # = MANIFEST =
  s.files = %w[
    README.rdoc
    Rakefile
    example/test.rb
    features/stats.feature
    features/step_definitions/stats_steps.rb
    features/step_definitions/window_steps.rb
    features/window.feature
    lib/sliding-stats.rb
    lib/sliding-stats/controller.rb
    lib/sliding-stats/persist.rb
    lib/sliding-stats/stats.rb
    lib/sliding-stats/view.rb
    lib/sliding-stats/window.rb
    sliding-stats.gemspec
  ]
  # = MANIFEST =
 
  s.test_files = s.files.select {|path| path =~ /^test\/spec_.*\.rb/}
 
  s.extra_rdoc_files = %w[]
  s.add_dependency 'rack', '>= 0.9.1'
  #s.add_development_dependency 'json', '>= 1.1'
 
  s.has_rdoc = true
  s.homepage = "http://www.hokstad.com/slidingstats"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "slidingstats", "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
