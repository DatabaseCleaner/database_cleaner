require 'active_record'

["two","one"].each do |db|
  ActiveRecord::Base.establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_#{db}.db")
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS "active_record_widgets"')
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS "active_record_widget_using_database_ones"')
  ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS "active_record_widget_using_database_twos"')
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :active_record_widgets do |t|
      t.string :name
    end

    create_table :active_record_widget_usings_database_ones do |t|
      t.string :name
    end
    
    create_table :active_record_widget_usings_database_twos do |t|
      t.string :name
    end
  end
end

class ActiveRecordWidget < ActiveRecord::Base
end

class ActiveRecordWidgetUsingDatabaseOne < ActiveRecord::Base
  establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_one.db")
end

class ActiveRecordWidgetUsingDatabaseTwo < ActiveRecord::Base
  establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => "#{DB_DIR}/activerecord_two.db")
end
