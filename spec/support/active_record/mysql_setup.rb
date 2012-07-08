module MySQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  @@mysql_db_spec = {
    :adapter  => 'mysql',
    :host => 'localhost',
    :username => 'root',
    :password => '',
    :encoding => 'utf8'
  }

  @@db = {:database => 'database_cleaner_test'}

  def active_record_mysql_setup
    ActiveRecord::Base.establish_connection(@@mysql_db_spec)

    ActiveRecord::Base.connection.drop_database @@db[:database] rescue nil  
    ActiveRecord::Base.connection.create_database @@db[:database]

    ActiveRecord::Base.establish_connection(@@mysql_db_spec.merge(@@db))

    ActiveRecord::Schema.define do
      create_table :users, :force => true do |t|
        t.integer :name
      end
    end
  end

  def active_record_mysql_connection 
    ActiveRecord::Base.connection
  end

  class ::User < ActiveRecord::Base
  end
end

RSpec.configure do |c|
  c.include MySQLHelper
end
