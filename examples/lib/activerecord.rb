require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :widgets do |t|
    t.string :name
  end
end

class Widget < ActiveRecord::Base
end
