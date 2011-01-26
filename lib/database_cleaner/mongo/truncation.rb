module DatabaseCleaner
  module Mongo
    module Truncation
      
      def clean
        if @only
          collections.each { |c| remove(c) if @only.include?(c.name) }
        else
          collections.each { |c| remove(c) unless @tables_to_exclude.include?(c.name) }
        end
        true
      end

      private
      
      def remove(collection)
        collection.drop_indexes
        collection.remove
      end

      def collections
        database.collections.select { |c| c.name !~ /^system/ }
      end

    end
  end
end
