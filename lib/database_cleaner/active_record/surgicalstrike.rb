require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require 'database_cleaner/active_record/base'
require 'database_cleaner/generic/surgicalstrike'

module ActiveRecord
  class Base
    include ::DatabaseCleaner::Generic::Dataholder
    extend ActiveRecord::Callbacks

    after_create :add_vip

    private
    def add_vip
      checktarget(self)
    end
  end

  module ConnectionAdapters

    class AbstractAdapter
      def views
        @views ||= select_values("select table_name from information_schema.views where table_schema = '#{current_database}'") rescue []
      end
    end
  end
end

module DatabaseCleaner::ActiveRecord
  class Surgicalstrike
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Dataholder
    include ::DatabaseCleaner::Generic::Surgicalstrike

    def start
      connection = connection_klass.connection
   
      $strike_targets = tables_to_strike(connection)
      $vips = Array.new
    end

    def clean
      strike_tables
    end


    private
    def strike_tables
      $vips = $vips.reverse
      $vips.each do |record|
          record.delete
      end
    end

    def tables_to_strike(connection)
      (@only || connection.tables) - @tables_to_exclude - connection.views
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end
  end
end