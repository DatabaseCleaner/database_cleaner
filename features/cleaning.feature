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
    | Redis        | truncation  |
