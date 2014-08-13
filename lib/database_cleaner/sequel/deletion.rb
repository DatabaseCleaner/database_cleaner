require "database_cleaner/sequel/base"
require "database_cleaner/generic/truncation"
require "database_cleaner/sequel/truncation"

module DatabaseCleaner::Sequel
  class Deletion < Truncation
    def clean
      db.transaction do
        case db.database_type
        when :postgres
          db.run "SET CONSTRAINTS ALL DEFERRED"
          tables_to_truncate(db).each do |table|
            db.run "ALTER TABLE #{::Sequel.lit(table)} DISABLE TRIGGER ALL"
          end
        when :mysql
          db.run "SET FOREIGN_KEY_CHECKS = 0"
        end
        each_table do |db, table|
          db[table].delete
        end
      end
    ensure
      case db.database_type
      when :postgres
        tables_to_truncate(db).each do |table|
          db.run "ALTER TABLE #{::Sequel.lit(table)} ENABLE TRIGGER ALL"
        end
      when :mysql
        db.run "SET FOREIGN_KEY_CHECKS = 1"
      end
    end
  end
end
