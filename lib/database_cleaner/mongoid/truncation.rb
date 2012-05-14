require 'database_cleaner/mongoid/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation'
require 'database_cleaner/moped/truncation'

module DatabaseCleaner
  module Mongoid
    class Truncation
      include ::DatabaseCleaner::Mongoid::Base
      include ::DatabaseCleaner::Generic::Truncation

      if ::Mongoid::VERSION < '3'

        include ::DatabaseCleaner::Mongo::Truncation

        private

        def database
          ::Mongoid.database
        end

      else

        include ::DatabaseCleaner::Moped::Truncation

        private

        def session
          ::Mongoid.default_session
        end

      end

    end
  end
end
