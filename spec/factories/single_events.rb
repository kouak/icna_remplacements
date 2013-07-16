# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_event do
    name "Event title"
    starttime Time.now
    endtime Time.now
    all_day true
    description "Description"
    user

    factory :single_event_now do
      name "Now"
      starttime { Time.now }
      endtime { Time.now }
      all_day true
    end
    
    factory :single_event_ten_days_before do
      name "Before"
      starttime { Time.now-10.days } 
      endtime { Time.now-10.days }
      all_day true
    end

    factory :single_event_ten_days_after do
      name "After"
      starttime { Time.now+10.days }
      endtime { Time.now+10.days }
      all_day true
    end
  end
end
