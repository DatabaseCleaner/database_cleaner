Feature: database cleaning using multiple ORMs
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app
    Given I am using <ORM1> and <ORM2>

    When I run my scenarios that rely on clean databases using multiple orms
    Then I should see all green

  Examples:
    | ORM1         | ORM2         |
    | ActiveRecord | DataMapper   |
    | ActiveRecord | Sequel       |
    | ActiveRecord | MongoMapper  |
    | ActiveRecord | Mongoid      |
    | ActiveRecord | CouchPotato  |
    | ActiveRecord | Ohm          |
    | ActiveRecord | Redis        |
    | DataMapper   | ActiveRecord |
    | DataMapper   | Sequel       |
    | DataMapper   | MongoMapper  |
    | DataMapper   | Mongoid      |
    | DataMapper   | CouchPotato  |
    | DataMapper   | Ohm          |
    | DataMapper   | Redis        |
    | Sequel       | ActiveRecord |
    | Sequel       | DataMapper   |
    | Sequel       | MongoMapper  |
    | Sequel       | Mongoid      |
    | Sequel       | CouchPotato  |
    | Sequel       | Ohm          |
    | Sequel       | Redis        |
    | MongoMapper  | ActiveRecord |
    | MongoMapper  | DataMapper   |
    | MongoMapper  | Sequel       |
    | MongoMapper  | Mongoid      |
    | MongoMapper  | CouchPotato  |
    | MongoMapper  | Ohm          |
    | MongoMapper  | Redis        |
    | CouchPotato  | ActiveRecord |
    | CouchPotato  | DataMapper   |
    | CouchPotato  | Sequel       |
    | CouchPotato  | MongoMapper  |
    | CouchPotato  | Mongoid      |
    | CouchPotato  | Ohm          |
    | CouchPotato  | Redis        |
    | Ohm          | ActiveRecord |
    | Ohm          | DataMapper   |
    | Ohm          | Sequel       |
    | Ohm          | MongoMapper  |
    | Ohm          | Mongoid      |
    | Ohm          | CouchPotato  |
    | Redis        | ActiveRecord |
    | Redis        | DataMapper   |
    | Redis        | Sequel       |
    | Redis        | MongoMapper  |
    | Redis        | Mongoid      |
    | Redis        | CouchPotato  |
    | Redis        | Ohm          |
    | Neo4j        | ActiveRecord |
    | Neo4j        | DataMapper   |
    | Neo4j        | Sequel       |
    | Neo4j        | Redis        |
    | Neo4j        | Ohm          |
    | Neo4j        | MongoMapper  |
