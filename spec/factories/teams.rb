# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    team 11
    first_day_in_cycle Date.today
  end
end
