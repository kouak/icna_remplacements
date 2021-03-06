### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :name => "McUserton", :email => "example@example.com",
    :password => "please", :password_confirmation => "please", :first_name => 'Testy', :team => FactoryGirl.create(:team), :detailed => false }
end

def find_user
  @user ||= User.find_by :email => @visitor[:email]
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit path_to 'the sign out page'
end

def create_user
  create_visitor
  delete_user
  @user = FactoryGirl.create(:user, email: @visitor[:email])
  @user.remove_role :admin
  @user
end

def create_admin
  create_user.add_role :admin
end

def delete_user
  @user ||= User.find_by :email => @visitor[:email]
  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit path_to 'the sign up page'
  fill_in I18n.t('activerecord.attributes.user.first_name'), :with => @visitor[:first_name]
  fill_in I18n.t('activerecord.attributes.user.name'), :with => @visitor[:name]
  check I18n.t('activerecord.attributes.user.detailed') if @visitor[:detailed] === true
  select @visitor[:team].to_s, :from => 'user_team_id'
  fill_in I18n.t('activerecord.attributes.user.email'), :with => @visitor[:email]
  fill_in I18n.t('activerecord.attributes.user.password'), :with => @visitor[:password]
  fill_in I18n.t('activerecord.attributes.user.password_confirmation'), :with => @visitor[:password_confirmation]
  click_button I18n.t('devise.registrations.new.sign_up')
  find_user
end

def sign_in
  visit path_to 'the sign in page'
  fill_in I18n.t('activerecord.attributes.user.email'), :with => @visitor[:email]
  fill_in I18n.t('activerecord.attributes.user.password'), :with => @visitor[:password]
  click_button I18n.t('devise.sessions.new.sign_in')
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit path_to 'the sign out page'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I am logged in as an admin$/ do
  create_admin
  sign_in
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I am not an admin$/ do
  @user.remove_role :admin
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  step 'I go to the sign out page'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a team$/ do
  create_visitor
  @visitor = @visitor.merge(:team => "")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "please123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  visit path_to 'the account edit page'
  fill_in I18n.t('activerecord.attributes.user.name'), :with => "newname"
  fill_in I18n.t('activerecord.attributes.user.first_name'), :with => "new first name"
  fill_in I18n.t('activerecord.attributes.user.surname'), :with => "new surname"
  uncheck I18n.t('activerecord.attributes.user.detailed')
  fill_in I18n.t('activerecord.attributes.user.current_password'), :with => @visitor[:password]
  click_button I18n.t('devise.registrations.user.edit')
end

When /^I look at the list of users$/ do
  visit path_to 'the users page'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content I18n.t('devise.sessions.destroy.sign_out')
  page.should_not have_content I18n.t('devise.sessions.new.sign_in')
end

Then /^I should be signed out$/ do
  page.should have_content I18n.t('devise.registrations.new.sign_up')
  page.should have_content I18n.t('devise.sessions.new.sign_in')
  page.should_not have_content I18n.t('devise.sessions.destroy.sign_out')
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content I18n.t('devise.failure.unconfirmed')
end

Then /^I see a successful sign in message$/ do
  page.should have_content I18n.t('devise.sessions.signed_in')
end

Then /^I should see a successful sign up message$/ do
  page.should have_content I18n.t('devise.registrations.user.signed_up_but_unconfirmed')
end

Then /^I should see an invalid email message$/ do
  page.should have_content Regexp.new(Regexp.escape(I18n.t('activerecord.attributes.user.email')) + '.*' + Regexp.escape(I18n.t('errors.messages.invalid')))
end

Then /^I should see a missing team message$/ do
  page.should have_content Regexp.new(Regexp.escape(I18n.t('activerecord.models.team')) + '.*' +  Regexp.escape(I18n.t('errors.messages.blank')))
end

Then /^I should see a missing password message$/ do
  page.should have_content Regexp.new(Regexp.escape(I18n.t('activerecord.attributes.user.password')) + ".*" + Regexp.escape(I18n.t('errors.messages.blank')))
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content Regexp.new(Regexp.escape(I18n.t('activerecord.attributes.user.password')) + ".*" + Regexp.escape(I18n.t('errors.messages.confirmation')))
end

Then /^I should see a mismatched password message$/ do
  page.should have_content Regexp.new(Regexp.escape(I18n.t('activerecord.attributes.user.password')) + ".*"  + Regexp.escape(I18n.t('errors.messages.confirmation')))
end

Then /^I should see a signed out message$/ do
  page.should have_content I18n.t('devise.sessions.signed_out')
end

Then /^I see an invalid login message$/ do
  page.should have_content I18n.t('devise.failure.not_found_in_database')
end

Then /^I should see an account edited message$/ do
  page.should have_content I18n.t('devise.registrations.user.updated')
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:name]
end
