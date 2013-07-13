When /^I visit the admin panel$/ do
  visit '/admin'
end

Then /^I should see the admin panel$/ do
  step "I should be on the admin page"
end