require "rubygems"

require "bundler"
Bundler.setup

require 'rspec/core'
require 'rspec/mocks'

#require 'active_record'
#require 'mongo_mapper'

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'database_cleaner'

RSpec.configure do |config|
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end

alias running lambda
