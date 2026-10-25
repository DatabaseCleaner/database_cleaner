require_relative "./lib/database_cleaner/version"

Gem::Specification.new do |spec|
  spec.name        = "database_cleaner-core"
  spec.version     = DatabaseCleaner::VERSION
  spec.authors     = ["Ben Mabey", "Ernesto Tagwerker"]
  spec.email       = ["ernesto@ombulabs.com"]

  spec.summary     = "Strategies for cleaning databases. Can be used to ensure a clean slate for testing."
  spec.description = "Strategies for cleaning databases. Can be used to ensure a clean slate for testing."
  spec.homepage    = "https://github.com/DatabaseCleaner/database_cleaner"
  spec.license     = "MIT"

  spec.files         = `git ls-files -z lib History.rdoc LICENSE README.markdown`.split("\x0")- ["lib/database_cleaner.rb"] # should only exist in database_cleaner gem
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency "listen"
  spec.add_development_dependency "rspec"

  spec.add_development_dependency "cucumber", "~>3.0"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "database_cleaner-active_record"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner-redis"
end
