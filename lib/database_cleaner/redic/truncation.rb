require 'database_cleaner/redic/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module Redic
    class Truncation
      include ::DatabaseCleaner::Redic::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
        if @only
          @only.each do |term|
            connection.call('KEYS', term).each { |k| connection.call('DEL', k) }
          end
        elsif @tables_to_exclude
          keys_except = []
          @tables_to_exclude.each { |term| keys_except += connection.call('KEYS', term) }
          connection.call('KEYS', '*').each { |k| connection.call('DEL', k) unless keys_except.include?(k) }
        else
          connection.call('FLUSHDB')
        end
        connection.call('QUIT') unless url == :default
      end
    end
  end
end
