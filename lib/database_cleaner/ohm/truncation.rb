require 'database_cleaner/redic/truncation'

module DatabaseCleaner
  module Ohm
    class Truncation < ::DatabaseCleaner::Redic::Truncation

      private

      def default_redis
        ::Ohm.redis
      end

    end
  end
end
