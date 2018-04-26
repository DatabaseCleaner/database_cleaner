require "bundler/setup"

require 'rspec/core'
require 'rspec/mocks'

#require 'active_record'
#require 'mongo_mapper'

$:.unshift(__dir__)
$:.unshift(__dir__ + '/../lib')

require 'database_cleaner'

RSpec.configure do |config|

end

alias running lambda
