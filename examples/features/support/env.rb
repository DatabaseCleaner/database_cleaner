require 'bundler/setup'
require 'rspec/expectations'

DB_DIR = "#{__dir__}/../../db"

orm         = ENV['ORM']
another_orm = ENV['ANOTHER_ORM']
strategy    = ENV['STRATEGY']
multiple_db = ENV['MULTIPLE_DBS']

config = YAML::load(File.open("#{__dir__}/../../config/redis.yml"))
ENV['REDIS_URL'] = config['test']['url']
ENV['REDIS_URL_ONE'] = config['one']['url']
ENV['REDIS_URL_TWO'] = config['two']['url']

if orm && strategy
  $:.unshift "#{__dir__}/../../../lib"
  require 'database_cleaner'
  require 'database_cleaner/cucumber'
  require "#{__dir__}/../../lib/#{orm.downcase}_models"

  if another_orm
    require "#{__dir__}/../../lib/#{another_orm.downcase}_models"
  end

  if multiple_db
    DatabaseCleaner.app_root = "#{__dir__}/../.."
    orm_sym = orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym

    case orm_sym
    when :mongo_mapper
      DatabaseCleaner[ orm_sym, {:connection => 'database_cleaner_test_one'} ].strategy = strategy.to_sym
      DatabaseCleaner[ orm_sym, {:connection => 'database_cleaner_test_two'} ].strategy = strategy.to_sym
    when :redis, :ohm
      DatabaseCleaner[ orm_sym, {:connection => ENV['REDIS_URL_ONE']} ].strategy = strategy.to_sym
      DatabaseCleaner[ orm_sym, {:connection => ENV['REDIS_URL_TWO']} ].strategy = strategy.to_sym
    when :active_record
      DatabaseCleaner[:active_record, {:model => ActiveRecordWidgetUsingDatabaseOne} ].strategy = strategy.to_sym
      DatabaseCleaner[:active_record, {:model => ActiveRecordWidgetUsingDatabaseTwo} ].strategy = strategy.to_sym
    else
      DatabaseCleaner[ orm_sym, {:connection => :one} ].strategy = strategy.to_sym
      DatabaseCleaner[ orm_sym, {:connection => :two} ].strategy = strategy.to_sym
    end

  elsif another_orm
    DatabaseCleaner[         orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym ].strategy = strategy.to_sym
    DatabaseCleaner[ another_orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym ].strategy = strategy.to_sym
  else
    DatabaseCleaner.strategy = strategy.to_sym unless strategy == "default"
  end

else
  raise "Run 'ORM=ActiveRecord|DataMapper|MongoMapper|CouchPotato|Ohm|Redis [ANOTHER_ORM=...] [MULTIPLE_DBS=true] STRATEGY=transaction|truncation|default cucumber examples/features'"
end
