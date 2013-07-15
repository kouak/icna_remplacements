When /^I visit the admin panel$/ do
  visit path_to 'the admin panel'
end

Then /^I should see the admin panel$/ do
  step "I should be on the admin page"
end