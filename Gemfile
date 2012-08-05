source "http://rubygems.org"
# TODO: move these to the gemspec...

group :development do
  gem "rake"
  gem "ruby-debug"

  gem "bundler"
  gem "jeweler"

  gem "json_pure"

  #ORM's
  gem "activerecord"
  gem "datamapper",           "1.0.0"
    gem "dm-migrations",      "1.0.0"
    gem "dm-sqlite-adapter",  "1.0.0"
  gem "mongoid"
    gem "tzinfo"
    gem "mongo_ext"
    gem "bson_ext"
  gem "mongo_mapper"
  gem "couch_potato"
  gem "sequel",               "~>3.21.0"
  #gem "ibm_db"  # I don't want to add this dependency, even as a dev one since it requires DB2 to be installed
  gem 'mysql'
  gem 'mysql2'
  gem 'pg'

  gem 'guard-rspec'
end

group :test do
  gem "rspec-rails"
  gem "rspactor"
  gem "rcov"
  gem "ZenTest"
end

group :cucumber do
  gem "cucumber"
  gem 'sqlite3-ruby'
end
