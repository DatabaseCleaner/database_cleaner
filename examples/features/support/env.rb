require 'rubygems'
require 'spec/expectations'

begin
  require "#{File.dirname(__FILE__)}/../../lib/#{ENV['ORM']}"
rescue LoadError
  raise "I don't have the setup for the '#{ENV['ORM']}' ORM!"
end

$:.unshift(File.dirname(__FILE__) + '/../../../lib')
require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = ENV['STRATEGY'].to_sym


