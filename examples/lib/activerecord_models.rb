require 'active_record'
db_dir = "#{File.dirname(__FILE__)}/../db"

ActiveRecord::Base.establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{db_dir}/activerecord_one.db")
class SchemeInfo < ActiveRecord::Base
end

# check to see if the schema needs resetting (when using file based db)
begin
  
  result = ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations")
  raise StandardError unless result.first["version"] == "1"
  
rescue                                                                
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :widgets do |t|
      t.string :name
    end
  
    create_table :another_widgets do |t|
      t.string :name
    end
  end
  
end

unless defined? Widget
  class Widget < ActiveRecord::Base
  end
else
  class AnotherWidget < ActiveRecord::Base
  end  
end
