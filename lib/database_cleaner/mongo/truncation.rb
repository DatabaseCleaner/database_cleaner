module DatabaseCleaner
  module Mongo
    module Truncation

      def clean
        if @only
          collections.each { |c| c.remove if @only.include?(c.name) }
        else
          collections.each { |c| c.remove unless @tables_to_exclude.include?(c.name) }
        end
        true
      end

      private

      def collections_cache
        @@collections_cache ||= {}
      end

      def collections
        collections_cache[database.name] ||= database.collections.select { |c| c.name !~ /^system\./ }
      end
    end
  end
end
