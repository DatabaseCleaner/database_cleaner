require 'rubygems'
require 'spec/expectations'

require 'activerecord'
require '../../lib/database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :transaction #DatabaseCleaner::ActiveRecord::Transaction.new

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :widgets do |t|
    t.string :name
  end
end

class Widget < ActiveRecord::Base
end
