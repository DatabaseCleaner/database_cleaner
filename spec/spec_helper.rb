require 'rubygems'
require 'spec'
require 'activerecord'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'database_cleaner'

Spec::Runner.configure do |config|
  
end

alias running lambda
