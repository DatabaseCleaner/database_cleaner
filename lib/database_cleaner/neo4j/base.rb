require 'database_cleaner/generic/base'
require 'neo4j-core'

module DatabaseCleaner
  module Neo4j
    def self.available_strategies
      %w[transaction truncation deletion]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db == :default ? nil : desired_db
      end

      def db
        @db
      end

      def start
        if db_type == :embedded_db && !session.running?
          session.start
        else
          session
        end
      end

      def database
        db && default_db.merge(db) || default_db
      end

      def query(*args)
        if legacy_neo4j?
          session._query(*args)
        else
          session.query(*args)
        end
      end

      private

      def default_db
        {:type => default_db_type, :path => default_db_path}
      end

      def default_db_type
        :server_db
      end

      def default_db_path(type = default_db_type)
        type == :server_db ? 'http://localhost:7475/' : './db/test'
      end

      def db_type
        database[:type]
      end

      def db_path
        database[:path]
      end

      def db_params
        database.reject! { |key, _| [:type, :path].include? key }
      end

      def session
        @session ||= if database[:current_session]
                       database[:current_session]
                     elsif legacy_neo4j?
                       ::Neo4j::Session.open(db_type, db_path, db_params)
                     else
                       ::Neo4j::Core::CypherSession.new(adaptor)
                     end
      end

      def legacy_neo4j?
        ::Neo4j::Core::VERSION.to_f < 7
      end

      def adaptor
        case db_type.to_sym
        when :http
          ::Neo4j::Core::CypherSession::Adaptors::HTTP.new(db_path, db_params)
        when :embedded
          ::Neo4j::Core::CypherSession::Adaptors::Embedded.new(db_path, db_params)
        when :bolt
          ::Neo4j::Core::CypherSession::Adaptors::Bolt.new(db_path, db_params)
        else
          raise "Invalid adaptor #{db_type}"
        end
      end
    end
  end
end
