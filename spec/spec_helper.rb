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
  config.before :all do
    # port forwarding from docker host to localhost
    system 'socat -lf /dev/null TCP-LISTEN:6379,reuseaddr,fork,su=nobody TCP:redis.local:6379 &> /dev/null &'
    system 'socat -lf /dev/null TCP-LISTEN:27017,reuseaddr,fork,su=nobody TCP:mongodb.local:27017 &> /dev/null &'
    system 'socat -lf /dev/null TCP-LISTEN:5432,reuseaddr,fork,su=nobody TCP:postgres.local:5432 &> /dev/null &'
    system 'socat -lf /dev/null TCP-LISTEN:3306,reuseaddr,fork,su=nobody TCP:mysql.local:3306 &> /dev/null &'
  end
end

alias running lambda
