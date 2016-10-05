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
        tables = tables.reject { |table| db[table].count == 0 }
        truncate_tables(db, tables)
      end

      def truncate_tables(db, tables)
        tables.each do |table|
          db.from(table).truncate
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
        default_schema = case db.database_type
                         when :postgres then db["SELECT (current_schemas(false))[1]::text AS default_schema"].get(:default_schema)
                         end

        (qualified(@only, default_schema) || db_tables(db)) - qualified(@tables_to_exclude, default_schema)
      end

      def db_tables(db)
        case db.database_type
        when :postgres
          db.tables(qualify: true) do |ds|
            # This block is needed due to a bug in Sequel <= 4.39.0
            m = db.send(:output_identifier_meth)
            ds.select_append(:pg_namespace__nspname).map do |r|
              ::Sequel.qualify(m.call(r[:nspname]).to_s, m.call(r[:relname]).to_s)
            end
          end
        else
          db.tables
        end
      end

      def qualified(arr, default_schema)
        return nil unless arr
        m = db.send(:output_identifier_meth)

        return arr.map { |a| m.call(a) } unless default_schema

        arr.map do |table|
          case table
          when String
            ::Sequel.qualify(m.call(default_schema).to_s, m.call(table).to_s)
          when Symbol
            # Split the symbol along '__' but make sure at least two arguments are passed
            refs = ::Sequel.split_symbol(table).tap do |obj|
              obj[0] ||= default_schema
            end.compact
            ::Sequel.qualify(*refs.map { |r| m.call(r).to_s })
          when ::Sequel::SQL::Identifier
            ::Sequel.qualify(m.call(default_schema).to_s, m.call(table.value).to_s)
          else table
          end
        end
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
