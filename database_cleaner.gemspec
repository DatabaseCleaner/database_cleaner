
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "database_cleaner/version"

Gem::Specification.new do |spec|
  spec.name        = "database_cleaner"
  spec.version     = DatabaseCleaner::VERSION
  spec.authors     = ["Ben Mabey", "Ernesto Tagwerker"]
  spec.email       = ["ernesto@ombulabs.com"]

  spec.summary     = "Strategies for cleaning databases. Can be used to ensure a clean slate for testing."
  spec.description = "Strategies for cleaning databases. Can be used to ensure a clean slate for testing."
  spec.homepage    = "https://github.com/DatabaseCleaner/database_cleaner"
  spec.license     = "MIT"

  spec.files = [
    "CONTRIBUTE.markdown",
    "Gemfile.lock",
    "History.rdoc",
    "README.markdown",
    "Rakefile",
    "cucumber.yml"]
  spec.files += Dir['lib/**/*.rb']
  spec.files += Dir['adapters/**/lib/**/*.rb']

  spec.extra_rdoc_files = [
    "LICENSE",
    "README.markdown",
    "TODO"
  ]

  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency "listen"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
end
