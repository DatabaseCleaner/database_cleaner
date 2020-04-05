require 'bundler'

Bundler.setup
require 'rspec/expectations'
#require 'byebug'

DB_DIR = "#{File.dirname(__FILE__)}/../../db"

orm         = ENV['ORM']
another_orm = ENV['ANOTHER_ORM']
strategy    = ENV['STRATEGY']
multiple_db = ENV['MULTIPLE_DBS']

config = YAML::load(File.open("#{File.dirname(__FILE__)}/../../config/redis.yml"))
ENV['REDIS_URL'] = config['test']['url']
ENV['REDIS_URL_ONE'] = config['one']['url']
ENV['REDIS_URL_TWO'] = config['two']['url']

require "active_support/core_ext/string/inflections"

if orm && strategy
  require "#{File.dirname(__FILE__)}/../../lib/#{orm.downcase}_models"
  require "database_cleaner-#{orm.underscore}"

  if another_orm
    require "#{File.dirname(__FILE__)}/../../lib/#{another_orm.downcase}_models"
    require "database_cleaner-#{another_orm.underscore}"
  end

  require 'database_cleaner/cucumber'

  if multiple_db
    orm_sym = orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym

    case orm_sym
    when :redis
      DatabaseCleaner[orm_sym, connection: ENV['REDIS_URL_ONE']].strategy = strategy.to_sym
      DatabaseCleaner[orm_sym, connection: ENV['REDIS_URL_TWO']].strategy = strategy.to_sym
    when :active_record
      DatabaseCleaner[:active_record, model: ActiveRecordWidgetUsingDatabaseOne].strategy = strategy.to_sym
      DatabaseCleaner[:active_record, model: ActiveRecordWidgetUsingDatabaseTwo].strategy = strategy.to_sym
    end

  elsif another_orm
    DatabaseCleaner[        orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym].strategy = strategy.to_sym
    DatabaseCleaner[another_orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym].strategy = strategy.to_sym
  else
    DatabaseCleaner.strategy = strategy.to_sym unless strategy == "default"
  end

else
  raise "Run 'ORM=ActiveRecord|Redis [ANOTHER_ORM=...] [MULTIPLE_DBS=true] STRATEGY=transaction|truncation|default cucumber examples/features'"
end
