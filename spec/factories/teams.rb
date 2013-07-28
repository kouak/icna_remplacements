# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    team 1
    first_day_in_cycle Time.now
    factory :team_with_today_as_first_day do
      first_day_in_cycle Time.now
    end
    (2..12).each do |i|
      factory "team_#{i}".to_s do
        team i
      end
    end
  end
end
