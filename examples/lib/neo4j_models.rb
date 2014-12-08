require 'neo4j-core'
DatabaseCleaner[:neo4j, :connection => {:type => :server_db, :path => 'http://localhost:7474'}]

class Neo4jWidget < Neo4j::Node
  def self.create!(*args)
    create(*args)
  end

  def self.count
    Neo4j::Session.query.pluck('count(*) AS result').first
  end
end

class Neo4jWidgetUsingDatabaseOne < Neo4jWidget
end

class Neo4jWidgetUsingDatabaseTwo < Neo4jWidget
end
