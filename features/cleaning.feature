Feature: database cleaning
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app with adapter gems
    Given I am using <ORM> from its adapter gem
    And the <Strategy> cleaning strategy

    When I run my scenarios that rely on a clean database
    Then I should see all green

  Examples:
    | ORM          | Strategy    |
    | ActiveRecord | transaction |
    | ActiveRecord | truncation  |
    | ActiveRecord | deletion    |
    | CouchPotato  | truncation  |
    | DataMapper   | transaction |
    | DataMapper   | truncation  |
    | Mongoid      | truncation  |
    | MongoMapper  | truncation  |
    | Neo4j        | deletion    |
    | Neo4j        | truncation  |
    | Neo4j        | transaction |

  Scenario Outline: ruby app
    Given I am using <ORM>
    And the <Strategy> cleaning strategy

    When I run my scenarios that rely on a clean database
    Then I should see all green

  Examples:
    | ORM          | Strategy    |
    | ActiveRecord | transaction |
    | ActiveRecord | truncation  |
    | ActiveRecord | deletion    |
    | DataMapper   | transaction |
    | DataMapper   | truncation  |
    | Sequel       | transaction |
    | Sequel       | truncation  |
    | Sequel       | deletion    |
    | MongoMapper  | truncation  |
    | Mongoid      | truncation  |
    | CouchPotato  | truncation  |
    | Redis        | truncation  |
    | Ohm          | truncation  |
    | Neo4j        | deletion    |
    | Neo4j        | truncation  |
    | Neo4j        | transaction |
