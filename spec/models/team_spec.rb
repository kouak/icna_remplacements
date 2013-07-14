require 'spec_helper'

describe Team do

  before(:each) do
    @attr = { 
      :team => "11",
      :first_day_in_cycle => Date.today,
    }
  end


  it "should reject invalid first_day_in_cycle" do
    first_day_in_cycle = ['user@foo.com', nil, '123548']
    first_day_in_cycle.each do |t|
      team = Team.new(@attr.merge(:first_day_in_cycle => t))
      team.should_not be_valid
    end
  end

  it "should accept valid first_day_in_cycle" do
    first_day_in_cycle = [Date.today, Date.today-365, Date.today+450]
    first_day_in_cycle.each do |t|
      team = Team.new(@attr.merge(:first_day_in_cycle => t))
      team.should be_valid
    end
  end
end
