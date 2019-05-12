
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "database_cleaner/active_record/version"

Gem::Specification.new do |spec|
  spec.name          = "database_cleaner-active_record"
  spec.version       = DatabaseCleaner::ActiveRecord::VERSION
  spec.authors       = ["Ernesto Tagwerker"]
  spec.email         = ["ernesto@ombulabs.com"]

  spec.summary       = "Strategies for cleaning databases using ActiveRecord. Can be used to ensure a clean state for testing."
  spec.description   = "Strategies for cleaning databases using ActiveRecord. Can be used to ensure a clean state for testing."
  spec.homepage      = "https://github.com/DatabaseCleaner/database_cleaner-active_record"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "database_cleaner", "~> 1.8.0"
  spec.add_dependency "activerecord"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rspec", "~> 3.0"

  unless RUBY_PLATFORM =~ /java/
    spec.add_development_dependency 'mysql', '~> 2.9.1'
    spec.add_development_dependency 'mysql2'
    spec.add_development_dependency "activerecord-mysql2-adapter"
    spec.add_development_dependency 'pg'
    spec.add_development_dependency "sqlite3"
  else
    spec.add_development_dependency "activerecord-jdbc-adapter"
  end
end
