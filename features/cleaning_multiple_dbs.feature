Feature: multiple database cleaning
  In order to ease example and feature writing
  As a developer
  I want to have my databases in a clean state

  Scenario Outline: ruby app with adapter gems
    Given I am using <ORM> from its adapter gem
    And the <Strategy> cleaning strategy

    When I run my scenarios that rely on clean databases
    Then I should see all green

  Examples:
    | ORM          | Strategy    |
    | ActiveRecord | truncation  |
    | ActiveRecord | deletion    |
    | ActiveRecord | transaction |
    | Redis        | deletion    |

