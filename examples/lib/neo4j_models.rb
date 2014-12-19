require 'neo4j-core'

class Neo4jWidget < Neo4j::Node
  def self.create!(*args)
    create(*args)
  end

  def self.count
    Neo4j::Session.query.match('n').pluck('COUNT(n)').first
  end
end

class Neo4jWidgetUsingDatabaseOne < Neo4jWidget
end

class Neo4jWidgetUsingDatabaseTwo < Neo4jWidget
end
