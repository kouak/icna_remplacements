# Read about factories at https://github.com/thoughtbot/factory_girl


FactoryGirl.define do
    sequence(:email) { |n| "example#{n}@example.com" }
    factory :user do
        name 'NOM'
        first_name 'Prenom'
        surname 'Surnom'
        detailed false
        email
        password 'please'
        password_confirmation 'please'
        # required if the Devise Confirmable module is used
        confirmed_at Time.now
        
        # associations
        team

    end

    factory :user_with_single_events, :parent => :user do
        after :create do |u, e|
            FactoryGirl.create(:single_event_now, :user => u)
            FactoryGirl.create(:single_event_ten_days_after, :user => u)
            FactoryGirl.create(:single_event_ten_days_before, :user => u)
            FactoryGirl.create(:single_event_tomorow_with_override, :user => u)
        end
    end
end
