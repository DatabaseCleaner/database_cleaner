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
    | ActiveRecord | MongoMapper  |
    | ActiveRecord | Mongoid      |
    | ActiveRecord | CouchPotato  |
    | ActiveRecord | Ohm          |
    | ActiveRecord | Redis        |
    | DataMapper   | ActiveRecord |
    | DataMapper   | MongoMapper  |
    | DataMapper   | Mongoid      |
    | DataMapper   | CouchPotato  |
    | DataMapper   | Ohm          |
    | DataMapper   | Redis        |
    | MongoMapper  | ActiveRecord |
    | MongoMapper  | DataMapper   |
    | MongoMapper  | Mongoid      |
    | MongoMapper  | CouchPotato  |
    | MongoMapper  | Ohm          |
    | MongoMapper  | Redis        |
    | CouchPotato  | ActiveRecord |
    | CouchPotato  | DataMapper   |
    | CouchPotato  | MongoMapper  |
    | CouchPotato  | Mongoid      |
    | CouchPotato  | Ohm          |
    | CouchPotato  | Redis        |
    | Ohm          | ActiveRecord |
    | Ohm          | DataMapper   |
    | Ohm          | MongoMapper  |
    | Ohm          | Mongoid      |
    | Ohm          | CouchPotato  |
    | Redis        | ActiveRecord |
    | Redis        | DataMapper   |
    | Redis        | MongoMapper  |
    | Redis        | Mongoid      |
    | Redis        | CouchPotato  |
    | Redis        | Ohm          |
