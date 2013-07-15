When /^I go to (.+?)$/ do |page_name|
  visit path_to(page_name)
end

Then /^I should be on (the .+? page)$/ do |page_name|
  puts "I should be on the #{page_name}"
  current_path.should eql(path_to(page_name))
  page.driver.status_code.to_i.should eql(200)
end

Then /^I should be redirected to the (.+?) page$/ do |page_name|
  step "I should be on the #{page_name} page"
end


Then /^I debug$/ do
  debugger
  0
end
