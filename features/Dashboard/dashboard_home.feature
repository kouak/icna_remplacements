Feature: Dashboard home
  In order to get an overview of my remplacements
  An user
  Should be able to access dashboard home

  Scenario: User is not signed in
    Given I do not exist as a user
    When I go to the home page
    Then I should be on the home page

  Scenario: User is signed in
    Given I am logged in
    When I go to the home page
    Then I should be on the dashboard home page