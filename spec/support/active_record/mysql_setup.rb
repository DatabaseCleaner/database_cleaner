require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module MySQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def active_record_mysql_setup
    ActiveRecord::Base.establish_connection db_config['mysql']
    load_schema
  end

  def active_record_mysql_connection 
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQLHelper
end
