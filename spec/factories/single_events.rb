# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_event do
    name "MyString"
    starttime "2013-07-15 17:47:33"
    endtime "2013-07-15 17:47:33"
    all_day false
    description "MyString"
    user_id 1
  end
end
