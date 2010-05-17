require 'rubygems'
Bundler.setup
require 'spec/expectations'
require 'ruby-debug'

orm         = ENV['ORM']
another_orm = ENV['ANOTHER_ORM']
strategy    = ENV['STRATEGY']

if orm && strategy

  begin            
    require "#{File.dirname(__FILE__)}/../../lib/#{orm}_models"    
  rescue LoadError => e   
    raise "You don't have the #{orm} ORM installed"
  end
  
  if another_orm
     begin            
      require "#{File.dirname(__FILE__)}/../../lib/#{another_orm}_models"    
    rescue LoadError => e   
      raise "You don't have the #{another_orm} ORM installed"
    end
  end

  $:.unshift(File.dirname(__FILE__) + '/../../../lib')
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = strategy.to_sym
  
else
  raise "Run 'ORM=activerecord|datamapper|mongomapper|couchpotato [ANOTHER_ORM=activerecord|datamapper|mongomapper|couchpotato] STRATEGY=transaction|truncation cucumber examples/features'"
end
