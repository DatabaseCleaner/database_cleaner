require 'active_record'

["two","one"].each do |db|
  ActiveRecord::Base.establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_#{db}.db")
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS "widgets"')
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS "another_widgets"')
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :widgets do |t|
      t.string :name
    end

    create_table :another_widgets do |t|
      t.string :name
    end
  end
end

class ActiveRecordWidgetBase < ActiveRecord::Base
  def self.establish_connection_one
    establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_one.db")
  end
  
  def self.establish_connection_two
    establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_two.db")
  end
end

unless defined? Widget
  class Widget < ActiveRecordWidgetBase
    set_table_name 'widgets'
  end
else
  class AnotherWidget < ActiveRecordWidgetBase
    set_table_name 'another_widgets'
  end
end
