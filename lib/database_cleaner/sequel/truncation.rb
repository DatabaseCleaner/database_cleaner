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

        case db.database_type
        when :postgres
          # PostgreSQL requires all tables with FKs to be truncates in the same command, or have the CASCADE keyword
          # appended. Bulk truncation without CASCADE is:
          # * Safer. Tables outside of tables_to_truncate won't be affected.
          # * Faster. Less roundtrips to the db.
          unless (tables = tables_to_truncate(db)).empty?
            db.from(*tables).truncate
          end
        else
          tables = tables_to_truncate(db)

          if pre_count?
            # Count rows before truncating
            pre_count_truncate_tables(db, tables)
          else
            # Truncate each table normally
            truncate_tables(db, tables)
          end
        end
      end

      private

      def pre_count_truncate_tables(db, tables)
        tables = tables.reject { |table| db[table.to_sym].count == 0 }
        truncate_tables(db, tables)
      end

      def truncate_tables(db, tables)
        tables.each do |table|
          db[table.to_sym].truncate
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
        tables = case db.database_type
                 when :postgres then postgres_tables(db)
                 else db.tables
                 end

        (@only || tables.map(&:to_sym)) - @tables_to_exclude.map(&:to_sym)
      end

      # overwritten
      def migration_storage_names
        %w(schema_info schema_migrations)
      end

      def pre_count?
        @pre_count == true
      end

      # Returns schema-qualified tables ordered by search_path
      def postgres_tables(db)
        rows = db[%{
          SELECT schemaname || '__' || tablename AS tablename
          FROM pg_tables
          WHERE
            tablename !~ '_prt_' AND
            schemaname = ANY (current_schemas(false))
          ORDER BY (SELECT idx FROM (
            SELECT generate_series(1, array_length(current_schemas(false), 1)) AS idx, unnest(current_schemas(false)) AS tbl
          ) foo WHERE foo.tbl::text = schemaname::text LIMIT 1)
        }]
        rows.collect { |result| result[:tablename].to_sym }
      end
    end
  end
end
