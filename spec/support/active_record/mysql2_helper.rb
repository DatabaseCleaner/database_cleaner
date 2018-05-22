require 'support/active_record/active_record_helper'

class MySQL2Helper < ActiveRecordHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  private

  def default_config
    db_config['mysql2']
  end
end

