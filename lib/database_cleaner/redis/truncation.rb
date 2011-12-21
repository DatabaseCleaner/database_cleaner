module DatabaseCleaner
  module Redis
    module Truncation

      def clean
        if @only
          @only.each do |term|
            database.keys(term).each { |k| database.del k }
          end
        elsif @tables_to_exclude
          keys_except = []
          @tables_to_exclude.each { |term| keys_except += database.keys(term) }
          database.keys.each { |k| database.del(k) unless keys_except.include?(k) }
        else
          database.flushdb
        end
      end

      def database

      end

    end
  end
end
