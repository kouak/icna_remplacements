Then /^I should see an (.+?) flash message$/ do |message_type|
  if message_type == "unauthorized"
    page.should have_content I18n.t('unauthorized.default')
  elsif message_type == "unauthenticated"
    page.should have_content I18n.t('devise.failure.unauthenticated')
  end
end
