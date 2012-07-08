module MySQL2Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  @@mysql2_db_spec = {
    :adapter  => 'mysql2',
    :host => 'localhost',
    :username => 'root',
    :password => '',
    :encoding => 'utf8'
  }

  @@db = {:database => 'database_cleaner_test'}

  def active_record_mysql2_setup
    ActiveRecord::Base.establish_connection(@@mysql2_db_spec)

    ActiveRecord::Base.connection.drop_database @@db[:database] rescue nil  
    ActiveRecord::Base.connection.create_database @@db[:database]

    ActiveRecord::Base.establish_connection(@@mysql2_db_spec.merge(@@db))

    ActiveRecord::Schema.define do
      create_table :users, :force => true do |t|
        t.integer :name
      end
    end
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end

  class ::User < ActiveRecord::Base
  end
end

RSpec.configure do |c|
  c.include MySQL2Helper
end
