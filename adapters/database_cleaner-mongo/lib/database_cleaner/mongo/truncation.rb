require 'database_cleaner/mongo/base'
require 'database_cleaner/generic/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'
require 'database_cleaner/deprecation'

module DatabaseCleaner
  module Mongo
    class Truncation
      include ::DatabaseCleaner::Generic::Base
      include ::DatabaseCleaner::Generic::Truncation
      include TruncationMixin
      include Base

      def initialize(opts={})
        super
        if !opts.has_key?(:cache_tables) || opts[:cache_tables]
          DatabaseCleaner.deprecate "The mongo adapter caches collection names between cleanings. However, this behavior can introduce test-order-dependency issues, because the collections that exist after the first test has executed are saved and used for the remainder of the suite. This means that any collection created during the subsequent tests are not cleaned! This is fixed in database_cleaner-mongo 2.0 by removing this collection caching functionality altogether. To ease the transition into this new behavior, it can be opted into by specifying the `:cache_tables` option to false: `DatabaseCleaner[:mongo].strategy = :deletion, cache_tables: false`. For more information, see https://github.com/DatabaseCleaner/database_cleaner/pull/646"
        end
      end

      private

      def database
        db
      end

      def collections_cache
        @collections_cache ||= {}
      end

      def mongoid_collection_names
        @mongoid_collection_names ||= Hash.new{|h,k| h[k]=[]}.tap do |names|
          ObjectSpace.each_object(Class) do |klass|
            (names[klass.db.name] << klass.collection_name) if valid_collection_name?(klass)
          end
        end
      end

      def not_caching(db_name, list)
        @not_caching ||= {}

        unless @not_caching.has_key?(db_name)
          @not_caching[db_name] = true

          puts "Not caching collection names for db #{db_name}. Missing these from models: #{list}"
        end
      end

      def collections
        return collections_cache[database.name] if collections_cache.has_key?(database.name) && @cache_tables
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
