require "rubygems"
require "bundler"
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

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
end

task :default => [:check_connections, :spec, :features]


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

desc "Check if all databases can be connected"
task :check_connections do
  ["redis.local 6379", "mongodb.local 27017", "postgres.local 5432", "mysql.local 3306"].each do |host_port|
    tries = 1
    while !system("nc -vz #{host_port}")
      if tries > 10
        abort "! max retries exceeded to connect to #{host_port}."
      end
      tries += 1
      sleep 3
    end
  end
end
