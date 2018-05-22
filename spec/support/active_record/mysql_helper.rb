require 'support/active_record/active_record_helper'

class MySQLHelper < ActiveRecordHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  def setup
    super
  end

  private

  def default_config
    db_config['mysql']
  end
end

