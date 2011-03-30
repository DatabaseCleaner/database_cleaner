require "database_cleaner/generic/truncation"
require 'database_cleaner/sequel/base'

module DatabaseCleaner
  module Sequel
    class Truncation
      include ::DatabaseCleaner::Sequel::Base
      include ::DatabaseCleaner::Generic::Truncation
  
      def clean
        each_table do |db, table|
          db[table].truncate
        end
      end
  
      def each_table
        tables_to_truncate(db).each do |table|
          yield db, table
        end
      end

      private
  
      def tables_to_truncate(db)
        (@only || db.tables) - @tables_to_exclude
      end
    end
  end
end


