source "http://rubygems.org"
# TODO: move these to the gemspec...

group :development do
  gem "rake"
  #gem "ruby-debug"

  gem "bundler"
  gem "jeweler"

  gem "json_pure"

  #ORM's
  gem "activerecord"
  gem "datamapper"
    gem "dm-migrations"
    gem "dm-sqlite-adapter"
  gem "mongoid"
    gem "tzinfo"
    gem "mongo_ext"
    gem "bson_ext"
  gem "mongo_mapper"
  gem "couch_potato"
  gem "sequel",               "~>3.21.0"
  #gem "ibm_db"  # I don't want to add this dependency, even as a dev one since it requires DB2 to be installed
  gem 'mysql', '~> 2.8.1'
  gem 'mysql2'
  gem 'pg'
  gem 'sqlite3'
  gem 'ohm', '~> 0.1.3'

  gem 'guard-rspec'
end

group :test do
  gem "rspec-rails"
  #gem "rspactor"
  #gem "rcov"
  #gem "ZenTest"
end

group :cucumber do
  gem "cucumber"
end

platforms :mri_18 do
  gem 'sqlite3-ruby', :group => :cucumber
  #gem 'mysql', :group => :development
end

platforms :mri_19 do
  gem 'sqlite3', :group => :cucumber
  #gem 'mysql2', :group => :development
end
