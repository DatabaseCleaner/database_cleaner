require "database_cleaner/generic/truncation"
require 'database_cleaner/data_mapper/base'




module DatabaseCleaner
  module DataMapper
    class Truncation
      include ::DatabaseCleaner::DataMapper::Base
      include ::DatabaseCleaner::Generic::Truncation
      
      def clean(repository = nil)
        repository = self.db if repository.nil?
        adapter = ::DataMapper.repository(repository).adapter
        adapter.disable_referential_integrity do
          tables_to_truncate(repository).each do |table_name|
            adapter.truncate_table table_name
          end
        end
      end

      private

      def tables_to_truncate(repository = nil)
        repository = self.db if repository.nil?
        (@only || ::DataMapper.repository(repository).adapter.storage_names(repository)) - @tables_to_exclude
      end

      # overwritten
      def migration_storage_name
        'migration_info'
      end

    end
  end
end
