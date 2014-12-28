require 'sequel'

db = Sequel.sqlite # memory database

db.run 'DROP TABLE IF EXISTS "sequel_widgets"'

db.create_table :sequel_widgets do
  String :name
end
