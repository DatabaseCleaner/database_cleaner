source "https://rubygems.org"

gemspec name: "database_cleaner-core"

gem "byebug"
gem "database_cleaner-active_record", git: "https://github.com/DatabaseCleaner/database_cleaner-active_record", branch: "new_adapter_api"
gem "database_cleaner-redis", git: "https://github.com/DatabaseCleaner/database_cleaner-redis", branch: "new_adapter_api"

group :test do
  gem "simplecov", require: false
  gem "codecov", require: false
end
