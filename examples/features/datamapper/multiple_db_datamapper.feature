Feature: example
 In order to test DataBase Cleaner
 Here are some scenarios that rely on the DB being clean!

  Background:
    Given I have setup database cleaner to clean multiple databases using datamapper

  Scenario: dirty the db
    When I create a widget in one db using datamapper
     And I create a widget in another db using datamapper
    Then I should see 1 widget in one db using datamapper
     And I should see 1 widget in another db using datamapper

  Scenario: assume a clean db
    When I create a widget in one db using datamapper
    Then I should see 1 widget in one db using datamapper
     And I should see 0 widget in another db using datamapper

  Scenario: assume a clean db
    When I create a widget in another db using datamapper
    Then I should see 0 widget in one db using datamapper
     And I should see 1 widget in another db using datamapper

