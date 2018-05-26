require 'database_cleaner/mongo/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'
module DatabaseCleaner
  module Mongo
    class Truncation
      include ::DatabaseCleaner::Generic::Truncation
      include TruncationMixin
      include Base
      private

      def database
        db
      end

      def collections_cache
        @@collections_cache ||= {}
      end

      def mongoid_collection_names
        @@mongoid_collection_names ||= Hash.new{|h,k| h[k]=[]}.tap do |names|
          ObjectSpace.each_object(Class) do |klass|
            (names[klass.db.name] << klass.collection_name) if valid_collection_name?(klass)
          end
        end
      end

      def not_caching(db_name, list)
        @@not_caching ||= {}

        unless @@not_caching.has_key?(db_name)
          @@not_caching[db_name] = true

          puts "Not caching collection names for db #{db_name}. Missing these from models: #{list}"
        end
      end

      def collections
        return collections_cache[database.name] if collections_cache.has_key?(database.name)
        db_collections = database.collections.select { |c| c.name !~ /^system\./ }

        missing_collections = mongoid_collection_names[database.name] - db_collections.map(&:name)

        if missing_collections.empty?
          collections_cache[database.name] = db_collections
        else
          not_caching(database.name, missing_collections)
        end

        db_collections
      end

      private

      def valid_collection_name?(klass)
        klass.ancestors.map(&:to_s).include?('Mongoid::Document') &&
        !klass.embedded &&
        !klass.collection_name.empty?
      end
    end
  end
end
