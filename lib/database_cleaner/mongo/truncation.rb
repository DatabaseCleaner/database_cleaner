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

      def mongoid_collection_names
        @@mongoid_collection_names ||= Hash.new{|h,k| h[k]=[]}.tap do |names|
          ObjectSpace.each_object(Class) do |klass|
            next unless klass.ancestors.include?(::Mongoid::Document)
            next if klass.embedded
            next if klass.collection_name.empty?
            names[klass.db.name] << klass.collection_name
          end
        end
      end

      def collections
        return collections_cache[database.name] if collections_cache.has_key?(database.name)
        db_collections = database.collections.select { |c| c.name !~ /^system\./ }

        missing_collections = db_collections.map(&:name) - mongoid_collection_names[database.name]

        if missing_collections.empty?
          collections_cache[database.name] = db_collections
        else
          puts "Not cacheing collection names. Missing these from models: #{missing_collections.inspect}"
        end

        return db_collections
      end
    end
  end
end
