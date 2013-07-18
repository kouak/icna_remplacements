# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_event do
    name "Event title"
    starttime Time.zone.now.beginning_of_day
    endtime Time.zone.now.end_of_day
    all_day true
    override_cycle false
    description "Description"
    user

    factory :single_event_now do
      name "Now"
      starttime { Time.zone.now.beginning_of_day }
      endtime { Time.zone.now.end_of_day }
      all_day true
    end

    factory :single_event_tomorow_with_override do
      name "Tomorow Override"
      starttime { (Time.zone.now + 1.day).beginning_of_day }
      endtime { (Time.zone.now + 1.day).end_of_day }
      all_day true
      override_cycle true
    end
    
    factory :single_event_ten_days_before do
      name "Before"
      starttime { (Time.zone.now-10.days).beginning_of_day } 
      endtime { (Time.zone.now-10.days).end_of_day }
      all_day true
    end

    factory :single_event_ten_days_after do
      name "After"
      starttime { (Time.zone.now+10.days).beginning_of_day }
      endtime { (Time.zone.now+10.days).end_of_day }
      all_day true
    end
  end
end
