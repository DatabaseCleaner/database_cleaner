Feature: database cleaning using multiple ORMs
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app with adapter gems
    Given I am using <ORM1> and <ORM2> from their adapter gems

    When I run my scenarios that rely on clean databases using multiple orms
    Then I should see all green

  Examples:
    | ORM1         | ORM2         |
    | ActiveRecord | CouchPotato  |
    | ActiveRecord | DataMapper   |
    | ActiveRecord | Mongoid      |
    | ActiveRecord | MongoMapper  |
    | ActiveRecord | Neo4j        |
    | ActiveRecord | Ohm          |
    | ActiveRecord | Redis        |
    | CouchPotato  | ActiveRecord |
    | CouchPotato  | DataMapper   |
    | CouchPotato  | Mongoid      |
    | CouchPotato  | MongoMapper  |
    | CouchPotato  | Neo4j        |
    | CouchPotato  | Ohm          |
    | CouchPotato  | Redis        |
    | DataMapper   | ActiveRecord |
    | DataMapper   | CouchPotato  |
    | DataMapper   | Mongoid      |
    | DataMapper   | MongoMapper  |
    | DataMapper   | Neo4j        |
    | DataMapper   | Ohm          |
    | DataMapper   | Redis        |
    | Mongoid      | ActiveRecord |
    | Mongoid      | CouchPotato  |
    | Mongoid      | DataMapper   |
    | Mongoid      | MongoMapper  |
    | Mongoid      | Neo4j        |
    | Mongoid      | Ohm          |
    | Mongoid      | Redis        |
    | MongoMapper  | ActiveRecord |
    | MongoMapper  | CouchPotato  |
    | MongoMapper  | DataMapper   |
    | MongoMapper  | Mongoid      |
    | MongoMapper  | Neo4j        |
    | MongoMapper  | Ohm          |
    | MongoMapper  | Redis        |
    | Neo4j        | ActiveRecord |
    | Neo4j        | CouchPotato  |
    | Neo4j        | DataMapper   |
    | Neo4j        | Mongoid      |
    | Neo4j        | MongoMapper  |
    | Neo4j        | Ohm          |
    | Neo4j        | Redis        |
    | Ohm          | ActiveRecord |
    | Ohm          | CouchPotato  |
    | Ohm          | DataMapper   |
    | Ohm          | Mongoid      |
    | Ohm          | MongoMapper  |
    | Ohm          | Neo4j        |
    | Ohm          | Redis        |
    | Redis        | ActiveRecord |
    | Redis        | DataMapper   |
    | Redis        | CouchPotato  |
    | Redis        | Mongoid      |
    | Redis        | MongoMapper  |
    | Redis        | Neo4j        |
    | Redis        | Ohm          |

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
