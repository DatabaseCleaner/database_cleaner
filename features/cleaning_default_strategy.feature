Feature: database cleaning
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state with default strategy

  Scenario Outline: ruby app
    Given All database servers are running locally
    And I am using <ORM>
    And the default cleaning strategy

    When I run my scenarios that rely on a clean database
    Then I should see all green

  Examples:
    | ORM          |
    | ActiveRecord |
    | DataMapper   |
    | Sequel       |
    | MongoMapper  |
    | Mongoid      |
    | CouchPotato  |
    | Redis        |
    | Ohm          |
    | Neo4j        |
