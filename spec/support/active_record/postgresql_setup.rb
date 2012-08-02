require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module PostgreSQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def active_record_pg_setup
    ActiveRecord::Base.establish_connection db_config['postgres']
    load_schema
  end

  def active_record_pg_connection 
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include PostgreSQLHelper
end
