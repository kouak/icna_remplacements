Feature: Show Users
  As a visitor to the website
  I want to see registered users listed on the homepage
  so I can know if the site has users

    Scenario: Viewing users
      Given I am logged in
      When I look at the list of users
      Then I should be redirected to the dashboard page
      And I should see an unauthorized flash message