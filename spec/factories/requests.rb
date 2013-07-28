# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :request do
    association :owner, :factory => :user
    date "2013-07-25 13:58:33"
  end
end
