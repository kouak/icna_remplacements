# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_event do
    name "Event title"
    starttime DateTime.now
    endtime DateTime.now
    all_day true
    description "Description"
    user

    factory :single_event_now do
      name "Now"
    end
    
    factory :single_event_ten_days_before do
      name "Before"
      starttime DateTime.now-10
      endtime DateTime.now-10
    end

    factory :single_event_ten_days_after do
      name "After"
      starttime DateTime.now+10
      endtime DateTime.now+10
    end
  end
end
