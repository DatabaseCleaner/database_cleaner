require 'database_cleaner/mongoid/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongoid/mongo1_truncation_mixin'
require 'database_cleaner/mongoid/mongo2_truncation_mixin'
require 'database_cleaner/mongoid/mongoid_truncation_mixin'
require 'mongoid/version'

module DatabaseCleaner
  module Mongoid
    class Truncation
      include ::DatabaseCleaner::Mongoid::Base
      include ::DatabaseCleaner::Generic::Truncation

      if ::Mongoid::VERSION < '3'

        include ::DatabaseCleaner::Mongoid::Mongo1TruncationMixin

        private

        def database
          ::Mongoid.database
        end

      elsif ::Mongoid::VERSION < '5'

        include ::DatabaseCleaner::Mongoid::MongoidTruncationMixin

        private

        def session
          ::Mongoid::VERSION > "5.0.0" ? ::Mongoid.default_client : ::Mongoid.default_session
        end

        def database
          if not(@db.nil? or @db == :default)
            ::Mongoid.databases[@db]
          else
            ::Mongoid.database
          end
        end

      else

        include ::DatabaseCleaner::Mongoid::Mongo2TruncationMixin

      end
    end
  end
end
