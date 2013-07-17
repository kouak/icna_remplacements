require 'spec_helper'

describe Team do

  before(:each) do
    @attr = { 
      :team => "11",
      :first_day_in_cycle => Time.now,
    }
  end

  it "should have a correct name" do
    team = Team.new(@attr.merge(:team => '11'))
    team.name.should eql('11')
    team.to_s.should eql('11')
  end

  it "should reject invalid first_day_in_cycle" do
    first_day_in_cycle = ['user@foo.com', nil]
    first_day_in_cycle.each do |t|
      team = Team.new(@attr.merge(:first_day_in_cycle => t))
      team.should_not be_valid
    end
  end

  it "should accept valid first_day_in_cycle" do
    first_day_in_cycle = [Time.now, Time.now-365, Time.now+450]
    first_day_in_cycle.each do |t|
      team = Team.new(@attr.merge(:first_day_in_cycle => t))
      team.should be_valid
    end
  end

  it "should have a valid cycle" do
    target = ['M1', 'J', 'S1', 'R1', 'R2', 'R3', 'M2', 'S2', 'N', 'R4', 'R5', 'R6']
    team = Team.new(@attr)
    team.cycle.to_a.should eql(target)
  end

  it "should refuse to set cycle with invalid arguments" do
    invalid = [
      # [:day_in_cycle, :date]
      [nil, nil],
      [nil, 'invalid'],
      [nil, 1],
      ['invalid', nil],
      [1, nil],
      [15, Time.now]
    ]

    invalid.each do |i|
      expect { Team.new(@attr).set_cycle_seed(:day_in_cycle => i[0], :date => i[1]) }.to raise_error
    end
  end

  it "should set cycle with valid arguments" do
    valid = { :day_in_cycle => 0, :date => Time.now }
    team = Team.new(@attr)
    expect { team.set_cycle_seed(valid) }.to_not raise_error
  end

  it "should correctly set_cycle_seed" do
    t = Date.today.in_time_zone - 3.days
    inputs = [
      # [ day_in_cycle, date ]
      [ 1, t ], # M1 today
      [ 7, t ], # M2 today
      [ 9, Date.new(2013, 7, 14).in_time_zone.to_time] # N on July 14th 2013
    ]

    results = []

    targets = [
      t, # Today
      t - 6.days, # M1 was six days ago
      Date.new(2013, 7, 6).in_time_zone.to_time # M1 on July 6th 2013
    ]

    inputs.each do |i|
      results << Team.new(@attr).set_cycle_seed(:date => i[1], :day_in_cycle => i[0]).first_day_in_cycle
    end

    targets.zip(results).each do |a, b|
      a.to_time.should eql(b.to_time)
    end
  end

  context "with seed data" do
    before(:each) do
      @team = Team.new(@attr)
      @team.set_cycle_seed :date => Time.now-1.day, :day_in_cycle => 2 # J yesterday => S1 today
    end

    it "should raise an error with invalid arguments" do
      expect { @Team.day_of_cycle?('caca') }.to raise_error
    end

    it "should return proper cycle day" do
      inputs = [Time.now, Time.now-12.days, Time.now-4.days, Time.now+1.days, Time.now+6.days, Time.now+24.days+1.days, Time.now+4.days]
      targets = ['S1', 'S1', 'R5', 'R1', 'N', 'R1', 'M2']

      c = @team.day_of_cycle
      c[:title].should eql('S1') # A call without argument should default to today

      inputs.each_with_index do |v,k|
        c = @team.day_of_cycle(v)
        c[:title].should eql(targets[k])
      end
    end
  end
end
