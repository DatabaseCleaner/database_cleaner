
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

  spec.rubygems_version = "2.4.5"
  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "json_pure"
  spec.add_development_dependency "activerecord-mysql2-adapter" unless RUBY_PLATFORM =~ /java/
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "datamapper"
  spec.add_development_dependency "dm-migrations"
  spec.add_development_dependency "dm-sqlite-adapter"
  spec.add_development_dependency "mongoid"
  spec.add_development_dependency "tzinfo"
  spec.add_development_dependency "mongoid-tree"
  spec.add_development_dependency "mongo_mapper"
  spec.add_development_dependency "mongo", "~> 1.12.0"
  spec.add_development_dependency "moped"
  spec.add_development_dependency "neo4j-core"
  spec.add_development_dependency "couch_potato"
  spec.add_development_dependency "sequel", "~> 3.21.0"
  spec.add_development_dependency 'ohm', '~> 0.1.3'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency "listen", "~> 3.0.0" # 3.1 requires Ruby >= 2.2
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"

  unless RUBY_PLATFORM =~ /java/
    spec.add_development_dependency "mongo_ext"
    spec.add_development_dependency "bson_ext"
    spec.add_development_dependency 'mysql', '~> 2.9.1'
    spec.add_development_dependency 'mysql2'
    spec.add_development_dependency 'pg'
    spec.add_development_dependency "sqlite3-ruby" if RUBY_VERSION < "1.9"
    spec.add_development_dependency "sqlite3" if RUBY_VERSION >= "1.9"
  else
    spec.add_development_dependency "activerecord-jdbc-adapter"
  end
end
