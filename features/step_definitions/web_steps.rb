Then /^I should be on the (.+?) page$/ do |page_name|

  if page_name == "sign in" || page_name == "login"
    page_name = 'new user session'
  elsif page_name == "admin"
    page_name = "rails admin"
  elsif page_name == "home"
    page_name = "root"
  end
  
  current_path.should eql(send("#{page_name.downcase.gsub(' ','_')}_path"))
  page.driver.status_code.to_i.should eql(200)
end

Then /^I should be redirected to the (.+?) page$/ do |page_name|
  step "I should be on the #{page_name} page"
end


Then /^I debug$/ do
  debugger
  0
end
