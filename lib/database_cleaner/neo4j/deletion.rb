require 'database_cleaner/neo4j/base'
require 'neo4j-core'

module DatabaseCleaner
  module Neo4j
    class Deletion
      include ::DatabaseCleaner::Neo4j::Base

      def clean
        ::Neo4j::Transaction.run { session._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r') }
        drop_indexes_and_constraints
      end

      private

      def drop_indexes_and_constraints
        return unless session.db_type == :server_db
        constraints = neo4j_rest_endpoint_query('constraint')
        constraints.each do |constraint|
          session._query("DROP CONSTRAINT ON (label:`#{constraint['label']}`) ASSERT label.#{constraint['property_keys'].first} IS UNIQUE")
        end

        indexes = neo4j_rest_endpoint_query('index')
        indexes.each do |index|
          session._query("DROP INDEX ON :`#{index['label']}`(#{index['property_keys'].first})")
        end
      end

      def neo4j_rest_endpoint_query(type)
        root_path = "#{database[:path]}db/data/schema/"
        uri = URI.parse("#{root_path}#{type}/")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request['Content-Type'] = 'application/json'
        response = http.request(request).body
        JSON.parse(response)
      end
    end
  end
end
