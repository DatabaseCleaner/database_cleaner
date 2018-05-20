require 'database_cleaner/generic/truncation'
require 'database_cleaner/sequel/base'

module DatabaseCleaner
  module Sequel
    class Truncation
      include ::DatabaseCleaner::Sequel::Base
      include ::DatabaseCleaner::Generic::Truncation

      def start
        @last_txid = txid
      end

      def clean
        return unless dirty?

        tables = tables_to_truncate(db)

        # Count rows before truncating
        if pre_count?
          tables = pre_count_tables(tables)
        end

        case db.database_type
        when :postgres
          # PostgreSQL requires all tables with FKs to be truncates in the same command, or have the CASCADE keyword
          # appended. Bulk truncation without CASCADE is:
          # * Safer. Tables outside of tables_to_truncate won't be affected.
          # * Faster. Less roundtrips to the db.
          unless tables.empty?
            tables_sql = tables.map { |t| %("#{t}") }.join(',')
            db.run "TRUNCATE TABLE #{tables_sql} RESTART IDENTITY;"
          end
        else
          truncate_tables(db, tables)
        end
      end

      private

      def pre_count_tables tables
        tables.reject { |table| db[table.to_sym].count == 0 }
      end

      def truncate_tables(db, tables)
        tables.each do |table|
          db[table.to_sym].truncate
          if db.database_type == :sqlite && db.table_exists?(:sqlite_sequence)
            db[:sqlite_sequence].where(name: table).delete
          end
        end
      end

      def dirty?
        @last_txid != txid || @last_txid.nil?
      end

      def txid
        case db.database_type
        when :postgres
          db.fetch('SELECT txid_snapshot_xmax(txid_current_snapshot()) AS txid').first[:txid]
        end
      end

      def tables_to_truncate(db)
        (@only || db.tables.map(&:to_s)) - @tables_to_exclude
      end

      # overwritten
      def migration_storage_names
        %w(schema_info schema_migrations)
      end

      def pre_count?
        @pre_count == true
      end
    end
  end
end
