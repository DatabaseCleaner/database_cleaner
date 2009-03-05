# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{database_cleaner}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey"]
  s.date = %q{2009-03-04}
  s.description = %q{TODO}
  s.email = %q{ben@benmabey.com}
  s.files = ["README.textile", "VERSION.yml", "examples/features", "examples/features/example.feature", "examples/features/step_definitions", "examples/features/step_definitions/example_steps.rb", "examples/features/support", "examples/features/support/env.rb", "examples/lib", "examples/lib/activerecord.rb", "lib/database_cleaner", "lib/database_cleaner/active_record", "lib/database_cleaner/active_record/transaction.rb", "lib/database_cleaner/active_record/truncation.rb", "lib/database_cleaner/configuration.rb", "lib/database_cleaner/cucumber.rb", "lib/database_cleaner/data_mapper", "lib/database_cleaner/data_mapper/transaction.rb", "lib/database_cleaner.rb", "features/cleaning.feature", "features/step_definitions", "features/step_definitions/database_cleaner_steps.rb", "features/support", "features/support/env.rb", "spec/database_cleaner", "spec/database_cleaner/active_record", "spec/database_cleaner/active_record/truncation_spec.rb", "spec/database_cleaner/configuration_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "Rakefile", "cucumber.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/bmabey/database_cleaner}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
