require 'database_cleaner/mongoid/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'
require 'database_cleaner/moped/truncation_base'
require 'mongoid/version'

module DatabaseCleaner
  module Mongoid
    class Truncation
      include ::DatabaseCleaner::Mongoid::Base
      include ::DatabaseCleaner::Generic::Truncation

      if ::Mongoid::VERSION < '3'

        include ::DatabaseCleaner::Mongo::TruncationMixin

        private

        def database
          ::Mongoid.database
        end

      elsif ::Mongoid::VERSION < '5'

        include ::DatabaseCleaner::Moped::TruncationBase

        private

        def session
          ::Mongoid.default_session
        end

        def database
          if not(@db.nil? or @db == :default)
            ::Mongoid.databases[@db]
          else
            ::Mongoid.database
          end
        end

      else

        def clean
          if @only
            collections.each { |c| database[c].find.delete_many if @only.include?(c) }
          else
            collections.each { |c| database[c].find.delete_many unless @tables_to_exclude.include?(c) }
          end
          true
        end

        private

        def collections
          if db != :default
            database.use(db)
          end

          database['system.namespaces'].find(:name => { '$not' => /\.system\.|\$/ }).to_a.map do |collection|
            _, name = collection['name'].split('.', 2)
            name
          end
        end

        def database
          if not(@db.nil? or @db == :default)
            ::Mongoid::Clients.with_name(@db)
          else
            ::Mongoid::Clients.default
          end
        end
      end
    end
  end
end
