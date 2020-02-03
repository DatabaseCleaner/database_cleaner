# testing
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# releasing
require "rake/clean"
CLOBBER.include "pkg"
require "bundler/gem_helper"
Bundler::GemHelper.install_tasks name: :database_cleaner
Bundler::GemHelper.install_tasks name: :"database_cleaner-core"
