require "dm-core"

# only to please activerecord API used in database_cleaner/examples/features/step_definitions
# yes, i know that's lazy ...
require "dm-validations"
require "dm-aggregates"

DataMapper.setup(:default, "sqlite3:#{DB_DIR}/datamapper_one.db")

class MapperWidget
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
end


unless defined? Widget
  class Widget < MapperWidget
  end
  
  Widget.auto_migrate!
else
  class AnotherWidget < MapperWidget
  end
  
  AnotherWidget.auto_migrate!
end