require 'database_cleaner/sequel/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/sequel/truncation'

module DatabaseCleaner::Sequel
  class Deletion < Truncation
    def disable_referential_integrity(tables)
      case db.database_type
      when :postgres
        db.run('SET CONSTRAINTS ALL DEFERRED')
        tables_to_truncate(db).each do |table|
          db.run("ALTER TABLE \"#{resolve_value(table.table)}\".\"#{resolve_value(table.column)}\" DISABLE TRIGGER ALL")
        end
      when :mysql
        old = db.fetch('SELECT @@FOREIGN_KEY_CHECKS').first[:@@FOREIGN_KEY_CHECKS]
        db.run('SET FOREIGN_KEY_CHECKS = 0')
      end
      yield
    ensure
      case db.database_type
      when :postgres
        tables.each do |table|
          db.run("ALTER TABLE \"#{resolve_value(table.table)}\".\"#{resolve_value(table.column)}\" ENABLE TRIGGER ALL")
        end
      when :mysql
        db.run("SET FOREIGN_KEY_CHECKS = #{old}")
      end
    end

    def resolve_value(value)
      value.respond_to?(:value) ? resolve_value(value.value) : value
    end

    def delete_tables(db, tables)
      tables.each do |table|
        db.from(table).delete
      end
    end

    def clean
      return unless dirty?

      tables = tables_to_truncate(db)
      db.transaction do
        disable_referential_integrity(tables) do
          delete_tables(db, tables)
        end
      end
    end
  end
end
