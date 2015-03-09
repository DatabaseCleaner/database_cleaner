version = YAML.load_file 'VERSION.yml'

Gem::Specification.new do |s|
  s.name = "database_cleaner"
  s.version = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ben Mabey"]
  s.date = "2015-01-02"
  s.description = "Strategies for cleaning databases. Can be used to ensure a clean state for testing."
  s.email = "ben@benmabey.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown",
    "TODO"
  ]
  s.files = [
    "CONTRIBUTE.markdown",
    "Gemfile.lock",
    "History.rdoc",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "cucumber.yml",
    "examples/Gemfile",
    "examples/Gemfile.lock",
    "examples/config/database.yml.example",
    "examples/config/redis.yml",
    "examples/db/sqlite_databases_go_here",
    "examples/features/example.feature",
    "examples/features/example_multiple_db.feature",
    "examples/features/example_multiple_orm.feature",
    "examples/features/step_definitions/activerecord_steps.rb",
    "examples/features/step_definitions/couchpotato_steps.rb",
    "examples/features/step_definitions/datamapper_steps.rb",
    "examples/features/step_definitions/mongoid_steps.rb",
    "examples/features/step_definitions/mongomapper_steps.rb",
    "examples/features/step_definitions/neo4j_steps.rb",
    "examples/features/step_definitions/translation_steps.rb",
    "examples/features/support/env.rb",
    "examples/lib/activerecord_models.rb",
    "examples/lib/couchpotato_models.rb",
    "examples/lib/datamapper_models.rb",
    "examples/lib/mongoid_models.rb",
    "examples/lib/mongomapper_models.rb",
    "examples/lib/neo4j_models.rb",
    "examples/lib/ohm_models.rb",
    "examples/lib/redis_models.rb",
    "examples/lib/sequel_models.rb",
    "features/cleaning.feature",
    "features/cleaning_default_strategy.feature",
    "features/cleaning_multiple_dbs.feature",
    "features/cleaning_multiple_orms.feature",
    "features/step_definitions/database_cleaner_steps.rb",
    "features/step_definitions/ohm_steps.rb",
    "features/step_definitions/redis_steps.rb",
    "features/support/env.rb",
    "features/support/feature_runner.rb",
    "lib/database_cleaner.rb",
    "lib/database_cleaner/active_record/base.rb",
    "lib/database_cleaner/active_record/deletion.rb",
    "lib/database_cleaner/active_record/transaction.rb",
    "lib/database_cleaner/active_record/truncation.rb",
    "lib/database_cleaner/base.rb",
    "lib/database_cleaner/configuration.rb",
    "lib/database_cleaner/couch_potato/base.rb",
    "lib/database_cleaner/couch_potato/truncation.rb",
    "lib/database_cleaner/cucumber.rb",
    "lib/database_cleaner/data_mapper/base.rb",
    "lib/database_cleaner/data_mapper/transaction.rb",
    "lib/database_cleaner/data_mapper/truncation.rb",
    "lib/database_cleaner/generic/base.rb",
    "lib/database_cleaner/generic/transaction.rb",
    "lib/database_cleaner/generic/truncation.rb",
    "lib/database_cleaner/mongo/base.rb",
    "lib/database_cleaner/mongo/truncation.rb",
    "lib/database_cleaner/mongo/truncation_mixin.rb",
    "lib/database_cleaner/mongo_mapper/base.rb",
    "lib/database_cleaner/mongo_mapper/truncation.rb",
    "lib/database_cleaner/mongoid/base.rb",
    "lib/database_cleaner/mongoid/truncation.rb",
    "lib/database_cleaner/moped/base.rb",
    "lib/database_cleaner/moped/truncation.rb",
    "lib/database_cleaner/moped/truncation_base.rb",
    "lib/database_cleaner/neo4j/base.rb",
    "lib/database_cleaner/neo4j/deletion.rb",
    "lib/database_cleaner/neo4j/transaction.rb",
    "lib/database_cleaner/neo4j/truncation.rb",
    "lib/database_cleaner/null_strategy.rb",
    "lib/database_cleaner/ohm/truncation.rb",
    "lib/database_cleaner/redis/base.rb",
    "lib/database_cleaner/redis/truncation.rb",
    "lib/database_cleaner/sequel/base.rb",
    "lib/database_cleaner/sequel/deletion.rb",
    "lib/database_cleaner/sequel/transaction.rb",
    "lib/database_cleaner/sequel/truncation.rb",
    "spec/database_cleaner/active_record/base_spec.rb",
    "spec/database_cleaner/active_record/transaction_spec.rb",
    "spec/database_cleaner/active_record/truncation/mysql2_spec.rb",
    "spec/database_cleaner/active_record/truncation/mysql_spec.rb",
    "spec/database_cleaner/active_record/truncation/postgresql_spec.rb",
    "spec/database_cleaner/active_record/truncation/shared_fast_truncation.rb",
    "spec/database_cleaner/active_record/truncation/sqlite3_spec.rb",
    "spec/database_cleaner/active_record/truncation_spec.rb",
    "spec/database_cleaner/base_spec.rb",
    "spec/database_cleaner/configuration_spec.rb",
    "spec/database_cleaner/couch_potato/truncation_spec.rb",
    "spec/database_cleaner/data_mapper/base_spec.rb",
    "spec/database_cleaner/data_mapper/transaction_spec.rb",
    "spec/database_cleaner/data_mapper/truncation/sqlite3_spec.rb",
    "spec/database_cleaner/data_mapper/truncation_spec.rb",
    "spec/database_cleaner/generic/base_spec.rb",
    "spec/database_cleaner/generic/truncation_spec.rb",
    "spec/database_cleaner/mongo/mongo_examples.rb",
    "spec/database_cleaner/mongo/truncation_spec.rb",
    "spec/database_cleaner/mongo_mapper/base_spec.rb",
    "spec/database_cleaner/mongo_mapper/mongo_examples.rb",
    "spec/database_cleaner/mongo_mapper/truncation_spec.rb",
    "spec/database_cleaner/moped/moped_examples.rb",
    "spec/database_cleaner/moped/truncation_spec.rb",
    "spec/database_cleaner/neo4j/base_spec.rb",
    "spec/database_cleaner/neo4j/transaction_spec.rb",
    "spec/database_cleaner/ohm/truncation_spec.rb",
    "spec/database_cleaner/redis/base_spec.rb",
    "spec/database_cleaner/redis/truncation_spec.rb",
    "spec/database_cleaner/sequel/base_spec.rb",
    "spec/database_cleaner/sequel/deletion_spec.rb",
    "spec/database_cleaner/sequel/transaction_spec.rb",
    "spec/database_cleaner/sequel/truncation/sqlite3_spec.rb",
    "spec/database_cleaner/sequel/truncation_spec.rb",
    "spec/database_cleaner/shared_strategy.rb",
    "spec/rcov.opts",
    "spec/spec_helper.rb",
    "spec/support/active_record/database_setup.rb",
    "spec/support/active_record/mysql2_setup.rb",
    "spec/support/active_record/mysql_setup.rb",
    "spec/support/active_record/postgresql_setup.rb",
    "spec/support/active_record/schema_setup.rb",
    "spec/support/active_record/sqlite3_setup.rb",
    "spec/support/data_mapper/schema_setup.rb",
    "spec/support/data_mapper/sqlite3_setup.rb"
  ]
  s.homepage = "http://github.com/DatabaseCleaner/database_cleaner"
  s.license = 'MIT'

  s.rubygems_version = "2.4.5"
  s.summary = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<datamapper>, [">= 0"])
      s.add_development_dependency(%q<dm-migrations>, [">= 0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 0"])
      s.add_development_dependency(%q<tzinfo>, [">= 0"])
      s.add_development_dependency(%q<mongo_ext>, [">= 0"])
      s.add_development_dependency(%q<bson_ext>, [">= 0"])
      s.add_development_dependency(%q<mongoid-tree>, [">= 0"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_development_dependency(%q<moped>, [">= 0"])
      s.add_development_dependency(%q<neo4j-core>, [">= 0"])
      s.add_development_dependency(%q<couch_potato>, [">= 0"])
      s.add_development_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_development_dependency(%q<mysql>, ["~> 2.8.1"])
      s.add_development_dependency(%q<mysql2>, [">= 0"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<ohm>, ["~> 0.1.3"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<datamapper>, [">= 0"])
      s.add_dependency(%q<dm-migrations>, [">= 0"])
      s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<mongo_ext>, [">= 0"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
      s.add_dependency(%q<mongoid-tree>, [">= 0"])
      s.add_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_dependency(%q<moped>, [">= 0"])
      s.add_dependency(%q<neo4j-core>, [">= 0"])
      s.add_dependency(%q<couch_potato>, [">= 0"])
      s.add_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_dependency(%q<mysql>, ["~> 2.8.1"])
      s.add_dependency(%q<mysql2>, [">= 0"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<ohm>, ["~> 0.1.3"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<ruby-debug19>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<datamapper>, [">= 0"])
    s.add_dependency(%q<dm-migrations>, [">= 0"])
    s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<mongo_ext>, [">= 0"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
    s.add_dependency(%q<mongoid-tree>, [">= 0"])
    s.add_dependency(%q<mongo_mapper>, [">= 0"])
    s.add_dependency(%q<moped>, [">= 0"])
    s.add_dependency(%q<neo4j-core>, [">= 0"])
    s.add_dependency(%q<couch_potato>, [">= 0"])
    s.add_dependency(%q<sequel>, ["~> 3.21.0"])
    s.add_dependency(%q<mysql>, ["~> 2.8.1"])
    s.add_dependency(%q<mysql2>, [">= 0"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<ohm>, ["~> 0.1.3"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
  end
end
