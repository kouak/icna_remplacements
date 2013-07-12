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
    Team.create!(:team => i.to_i)
  end
end


puts 'SETTING UP DEFAULT USER LOGIN'

if User.all.count == 0
  user = User.create! :first_name => 'First', :name => 'User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please', :confirmed_at => Time.now.utc, :team => Team.find(1), :detailed => false
  puts 'New user created: ' << user.to_s
else
  puts 'Found existing users, aborting'
end