Feature: Admin Panel
  In order to administrate the application
  An administrator
  Should be able to access control panel

  Scenario: User is not signed in
    Given I do not exist as a user
    When I visit the admin panel
    Then I should be redirected to the login page
    And I should see an unauthenticated message

  Scenario: User is signed in but not admin
    Given I am logged in
    When I visit the admin panel
    Then I should be redirected to the home page
    And I should see an unauthorized message

  Scenario: User is signed in and is admin
    Given I am logged in as an admin
    When I visit the admin panel
    Then I should see the admin panel