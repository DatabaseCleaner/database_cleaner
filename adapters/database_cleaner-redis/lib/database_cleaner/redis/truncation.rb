require 'database_cleaner/redis/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module Redis
    class Truncation
      include ::DatabaseCleaner::Redis::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
        if @only
          @only.each do |term|
            connection.keys(term).each { |k| connection.del k }
          end
        elsif @tables_to_exclude
          keys_except = []
          @tables_to_exclude.each { |term| keys_except += connection.keys(term) }
          connection.keys.each { |k| connection.del(k) unless keys_except.include?(k) }
        else
          connection.flushdb
        end
        connection.quit unless url == :default
      end
    end
  end
end
