module DatabaseCleaner
  module Mongo2
    module TruncationMixin

      def clean
        if @only
          collections.each { |c| database[c].find.delete_many if @only.include?(c) }
        else
          collections.each { |c| database[c].find.delete_many unless @tables_to_exclude.include?(c) }
        end
        true
      end

      private

      def database
        if @db.nil? || @db == :default
          ::Mongoid::Clients.default
        else
          ::Mongoid::Clients.with_name(@db)
        end
      end

      def collections
        if db != :default
          database.use(db)
        end

        database.collections.collect { |c| c.namespace.split('.',2)[1] }

        # database['system.namespaces'].find(:name => { '$not' => /\.system\.|\$/ }).to_a.map do |collection|
        #   _, name = collection['name'].split('.', 2)
        #   name
        # end
      end

    end
  end
end
