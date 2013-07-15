Feature: Dashboard home
  In order to get an overview of my remplacements
  An user
  Should be able to access dashboard home

  Scenario: User is not signed in
    Given I do not exist as a user
    When I go to the dashboard page
    Then I should be redirected to the login page
    And I should see an unauthenticated flash message

  Scenario: User is signed in
    Given I am logged in
    When I go to the dashboard page
    Then I should be on the dashboard home page