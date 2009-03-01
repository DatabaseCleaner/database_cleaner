require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'database_cleaner'

Spec::Runner.configure do |config|
  
end

alias running lambda
