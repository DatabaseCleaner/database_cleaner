require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require 'database_cleaner/active_record/base'
require 'database_cleaner/generic/surgicalstrike'

module ActiveRecord
  class Base
    include ::DatabaseCleaner::Generic::Dataholder
    extend ActiveRecord::Callbacks

    after_create :test

    private
    def test
      checktarget(self)
    end
  end

  module ConnectionAdapters

    class AbstractAdapter
      def views
        @views ||= select_values("select table_name from information_schema.views where table_schema = '#{current_database}'") rescue []
      end

      def self.strike_table(table_name)
        raise NotImplementedError
      end
    end

    class SQLServerAdapter < AbstractAdapter
      def self.strike_table(active_record_object) #Table_name is the hash key for the AR object
                                                  #oneach record in the hash key (the primary keys)
                                                  #get the primary id column name from the AR object
                                                  #get the table name from the AR object
                                                  #walk the array of PK's
                                                  #perform the delete
        execute("DELETE FROM #{quote_table_name(table_name)} WHERE #{quote_table_name(pk_name)} == #{pk_value}")
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
      #To_Do:
      #Need to begin watching the callback after_create in ActiveRecord::Base
      #Need to check after each callback to see if that particular ActiveRecord object exists in the hash
      #If it doesn't need to add it to the hash and add to that hash value the primary_key that was returned
      #If it does exist need to just add the primary key that it returned to that hash's data
      $strike_targets = tables_to_strike(connection)
      $vips = Array.new
    end

    def clean
      strike_tables #hash
    end


    private
    #This walks the hash of tables.
    def strike_tables #hash possibly passing in?
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