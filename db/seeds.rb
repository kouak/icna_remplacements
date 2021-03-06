# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'ADDING DEFAULT TEAM DATA'
if Team.all.count == 0
  (1..12).each do |i|
    Team.create!(:team => i.to_i, :first_day_in_cycle => Time.now) # set a dump first_day_in_cycle to avoid validation complaints
  end
end


puts 'RESETTNG TEAM CYCLE SEED'
# 14-07-2013 => Team 11 working N(ight)
# => 16-07-2013 => Team 1 working N(ight) (9th day of the cycle)
(1..12).each do |i|
  Team.where(:team => i).first.set_cycle_seed :date => Date.new(2013, 7, 16+(i-1)).in_time_zone.to_time, :day_in_cycle => 9 # TODO : Handle Timezone
end

puts 'SETTING UP DEFAULT USER LOGIN'
if User.all.count == 0
  user = User.create! :first_name => 'First', :name => 'User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please', :confirmed_at => Time.now.utc, :team => Team.find(1), :detailed => false
  puts 'New user created: ' << user.to_s
else
  puts 'Found existing users, aborting'
end

puts 'ADDING DUMB SINGLE_EVENT'
if User.first.single_events.count == 0
  SingleEvent.create!(
    :name => 'Dumb',
    :starttime => Time.now.beginning_of_day,
    :endtime => Time.now.end_of_day,
    :user => User.first,
    :all_day => true,
    :description => 'this is a description ...'
    )
end
