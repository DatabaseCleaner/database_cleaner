require "bundler/setup"
require "byebug"
require "rspec/expectations"

orm         = ENV['ORM']
another_orm = ENV['ANOTHER_ORM']
strategy    = ENV['STRATEGY']
multiple_db = ENV['MULTIPLE_DBS']

if ENV['COVERAGE'] == 'true'
  require "simplecov"
  simple_cov_key = "Inner Cucumber with #{[orm, another_orm, strategy, multiple_db].compact.join(", ")}"
  SimpleCov.command_name simple_cov_key

  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
    puts "required codecov"
  end

  SimpleCov.start
  puts "required simplecov"
end

DB_DIR = "#{File.dirname(__FILE__)}/../../db"

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
      cleaner = DatabaseCleaner[orm_sym, db: ENV['REDIS_URL_ONE']]
      cleaner.strategy = strategy.to_sym unless strategy == "default"
      cleaner = DatabaseCleaner[orm_sym, db: ENV['REDIS_URL_TWO']]
      cleaner.strategy = strategy.to_sym unless strategy == "default"
    when :active_record
      cleaner = DatabaseCleaner[:active_record, db: ActiveRecordWidgetUsingDatabaseOne]
      cleaner.strategy = strategy.to_sym unless strategy == "default"
      cleaner = DatabaseCleaner[:active_record, db: ActiveRecordWidgetUsingDatabaseTwo]
      cleaner.strategy = strategy.to_sym unless strategy == "default"
    end

  elsif another_orm
    cleaner = DatabaseCleaner[        orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym]
    cleaner.strategy = strategy.to_sym unless strategy == "default"
    cleaner = DatabaseCleaner[another_orm.gsub(/(.)([A-Z]+)/,'\1_\2').downcase.to_sym]
    cleaner.strategy = strategy.to_sym unless strategy == "default"
  else
    DatabaseCleaner.strategy = strategy.to_sym unless strategy == "default"
  end

else
  raise "Run 'ORM=ActiveRecord|Redis [ANOTHER_ORM=...] [MULTIPLE_DBS=true] STRATEGY=transaction|truncation|default cucumber examples/features'"
end
