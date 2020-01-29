require "rubygems"
require "bundler"
require "bundler/gem_tasks"
Bundler.setup

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

desc "Run adapter test suites"
task :adapters do
  Dir["adapters/*"].each do |adapter_dir|
    Dir.chdir adapter_dir do
      sh "bundle exec rake"
    end
  end
end

task :default => [:spec, :features, :adapters]

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
