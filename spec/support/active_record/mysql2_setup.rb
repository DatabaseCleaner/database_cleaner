require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module MySQL2Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def active_record_mysql2_setup
    ActiveRecord::Base.establish_connection db_config['mysql2']
    load_schema
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQL2Helper
end
