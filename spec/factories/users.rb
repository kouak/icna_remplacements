# Read about factories at https://github.com/thoughtbot/factory_girl


FactoryGirl.define do
  factory :user do
    name 'NOM'
    first_name 'Prenom'
    surname 'Surnom'
    detailed false
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    # required if the Devise Confirmable module is used
    confirmed_at Time.now
    
    association :team, :factory  => :team
  end
end
