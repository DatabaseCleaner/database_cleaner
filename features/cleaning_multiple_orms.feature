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
    | ActiveRecord | Redis        |
    | Redis        | ActiveRecord |

