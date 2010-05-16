Feature: multiple database cleaning
  In order to ease example and feature writing
  As a developer
  I want to have my database in a clean state

  Scenario Outline: ruby app
    Given I am using <ORM>
    And the <Strategy> cleaning strategy

    When I run my scenarios that rely on a clean database
    Then I should see all green

  Examples:
    | ORM 1        | ORM2         |
    | ActiveRecord | DataMapper   |
    | ActiveRecord | MongoMapper  |
    | DataMapper   | MongoMapper  |
    | DataMapper   | CouchPotato  |
    | MongoMapper  | CouchPotato  |
    | CouchPotato  | ActiveRecord |
