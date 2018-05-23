require 'sequel'
require 'database_cleaner/spec/database_helper'

class SequelHelper < DatabaseCleaner::Spec::DatabaseHelper
  private

  def establish_connection(config = default_config)
    url = "#{db}:///"
    url = "sqlite:///" if db == :sqlite3
    @connection = ::Sequel.connect(url, config)
  end
end
