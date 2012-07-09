module PostgreSQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  # createdb database_cleaner_test -E UTF8 -T template0

  @@pg_db_spec = {
    :adapter  => 'postgresql',
    :database => 'postgres',
    :host => '127.0.0.1',
    :username => 'postgres',
    :password => '',
    :encoding => 'unicode',
    :template => 'template0'
  }

  @@db = {:database => 'database_cleaner_test'}

  # ActiveRecord::Base.establish_connection(@@pg_db_spec)

  # ActiveRecord::Base.connection.drop_database db[:database] rescue nil  
  # ActiveRecord::Base.connection.create_database db[:database]

  def active_record_pg_setup
    ActiveRecord::Base.establish_connection(@@pg_db_spec.merge(@@db))
    
    ActiveRecord::Schema.define do
      create_table :users, :force => true do |t|
        t.integer :name
      end
    end
  end

  def active_record_pg_connection 
    ActiveRecord::Base.connection
  end

  class ::User < ActiveRecord::Base
  end
end

RSpec.configure do |c|
  c.include PostgreSQLHelper
end
