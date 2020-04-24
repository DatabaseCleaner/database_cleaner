require 'rspec/expectations'

if ENV['COVERAGE'] == 'true'
  require "simplecov"

  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
    puts "required codecov"
  end

  SimpleCov.start
  puts "required simplecov"
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'database_cleaner-core'

