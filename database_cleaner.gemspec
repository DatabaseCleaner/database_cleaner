# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "database_cleaner"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey"]
  s.date = "2013-03-04"
  s.description = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."
  s.email = "ben@benmabey.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown",
    "TODO"
  ]
  s.files = [
    "Gemfile.lock",
    "History.txt",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "cucumber.yml",
    "examples/Gemfile",
    "examples/Gemfile.lock",
    "examples/config/database.yml.example",
    "examples/db/sqlite_databases_go_here",
    "examples/features/example.feature",
    "examples/features/example_multiple_db.feature",
    "examples/features/example_multiple_orm.feature",
    "examples/features/step_definitions/activerecord_steps.rb",
    "examples/features/step_definitions/couchpotato_steps.rb",
    "examples/features/step_definitions/datamapper_steps.rb",
    "examples/features/step_definitions/mongoid_steps.rb",
    "examples/features/step_definitions/mongomapper_steps.rb",
    "examples/features/step_definitions/translation_steps.rb",
    "examples/features/support/env.rb",
    "examples/lib/activerecord_models.rb",
    "examples/lib/couchpotato_models.rb",
    "examples/lib/datamapper_models.rb",
    "examples/lib/mongoid_models.rb",
    "examples/lib/mongomapper_models.rb",
    "features/cleaning.feature",
    "features/cleaning_default_strategy.feature",
    "features/cleaning_multiple_dbs.feature",
    "features/cleaning_multiple_orms.feature",
    "features/step_definitions/database_cleaner_steps.rb",
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
    "lib/database_cleaner/moped/truncation.rb",
    "lib/database_cleaner/null_strategy.rb",
    "lib/database_cleaner/sequel/base.rb",
    "lib/database_cleaner/sequel/transaction.rb",
    "lib/database_cleaner/sequel/truncation.rb",
    "spec/database_cleaner/active_record/base_spec.rb",
    "spec/database_cleaner/active_record/transaction_spec.rb",
    "spec/database_cleaner/active_record/truncation/mysql2_spec.rb",
    "spec/database_cleaner/active_record/truncation/mysql_spec.rb",
    "spec/database_cleaner/active_record/truncation/postgresql_spec.rb",
    "spec/database_cleaner/active_record/truncation/shared_fast_truncation.rb",
    "spec/database_cleaner/active_record/truncation_spec.rb",
    "spec/database_cleaner/base_spec.rb",
    "spec/database_cleaner/configuration_spec.rb",
    "spec/database_cleaner/couch_potato/truncation_spec.rb",
    "spec/database_cleaner/data_mapper/base_spec.rb",
    "spec/database_cleaner/data_mapper/transaction_spec.rb",
    "spec/database_cleaner/data_mapper/truncation_spec.rb",
    "spec/database_cleaner/generic/base_spec.rb",
    "spec/database_cleaner/generic/truncation_spec.rb",
    "spec/database_cleaner/mongo/mongo_examples.rb",
    "spec/database_cleaner/mongo/truncation_spec.rb",
    "spec/database_cleaner/mongo_mapper/base_spec.rb",
    "spec/database_cleaner/mongo_mapper/mongo_examples.rb",
    "spec/database_cleaner/mongo_mapper/truncation_spec.rb",
    "spec/database_cleaner/sequel/base_spec.rb",
    "spec/database_cleaner/sequel/transaction_spec.rb",
    "spec/database_cleaner/sequel/truncation_spec.rb",
    "spec/database_cleaner/shared_strategy.rb",
    "spec/rcov.opts",
    "spec/spec_helper.rb",
    "spec/support/active_record/database_setup.rb",
    "spec/support/active_record/mysql2_setup.rb",
    "spec/support/active_record/mysql_setup.rb",
    "spec/support/active_record/postgresql_setup.rb",
    "spec/support/active_record/schema_setup.rb"
  ]
  s.homepage = "http://github.com/bmabey/database_cleaner"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."
  # TODO: Figure out openssl error before cutting final release...
  #s.signing_key = '/Users/bmabey/.gem_key/gem-private_key.pem'
  #s.cert_chain  = ['gem-public_cert.pem']
  if s.respond_to? :specification_version then
    s.specification_version = 3
  end

end

