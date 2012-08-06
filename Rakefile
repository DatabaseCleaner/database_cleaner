require "rubygems"
require "bundler"
Bundler.setup

require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "database_cleaner"
    s.summary = %Q{Strategies for cleaning databases.  Can be used to ensure a clean state for testing.}
    s.email = "ben@benmabey.com"
    s.homepage = "http://github.com/bmabey/database_cleaner"
    s.description = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."
    s.files = FileList["[A-Z]*.*", "{examples,lib,features,spec}/**/*", "Rakefile", "cucumber.yml"]
    s.authors = ["Ben Mabey"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
end

task :default => [:spec, :features]


desc "Cleans the project of any tmp file that should not be included in the gemspec."
task :clean do
  ["examples/config/database.yml", "examples/db/activerecord_one.db", "examples/db/activerecord_two.db", "examples/db/datamapper_default.db",
    "examples/db/datamapper_one.db", "examples/db/datamapper_two.db"].each do |f|
    FileUtils.rm_f(f)
  end
  %w[*.sqlite3 *.log #* *.swp *.swo].each do |pattern|
    `find . -name "#{pattern}" -delete`
  end
end

desc "Cleans the dir and builds the gem"
task :prep => [:clean, :gemspec, :build]
