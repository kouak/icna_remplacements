require 'spec_helper'

describe Team do

  before(:each) do
    @attr = { 
      :team => "11",
      :first_day_in_cycle => Date.today,
    }
  end

  it "should have a correct name" do
    team = Team.new(@attr.merge(:team => '11'))
    team.name.should eql('11')
    team.to_s.should eql('11')
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

  it "should have a valid cycle" do
    target = ['M1', 'J', 'S1', false, false, false, 'M2', 'S2', 'N', false, false, false]
    team = Team.new(@attr)
    team.cycle.should eql(target)
  end

  it "should refuse to set cycle with invalid arguments" do
    invalid = [
      # [:day_in_cycle, :date]
      [nil, nil],
      [nil, 'invalid'],
      [nil, 1],
      ['invalid', nil],
      [1, nil],
      [15, Date.today]
    ]

    invalid.each do |i|
      expect { Team.new(@attr).set_cycle_seed(:day_in_cycle => i[0], :date => i[1]) }.to raise_error
    end
  end

  it "should set cycle with valid arguments" do
    valid = { :day_in_cycle => 0, :date => Date.today }
    team = Team.new(@attr)
    expect { team.set_cycle_seed(valid) }.to_not raise_error
  end

  it "should correctly set_cycle_seed" do
    inputs = [
      # [ day_in_cycle, date ]
      [ 1, Date.today ], # M1 today
      [ 7, Date.today ], # M2 today
      [ 9, Date.new(2013, 7, 14)] # N on July 14th 2013
    ]
    results = []
    
    targets = [
      Date.today, # Today
      Date.today - 6, # Six days ago
      Date.new(2013, 7, 6) # M1 on July 6th 2013
    ]

    inputs.each do |i|
      results << Team.new(@attr).set_cycle_seed(:date => i[1], :day_in_cycle => i[0]).first_day_in_cycle
    end

    results.should eql(targets)
  end

  context "With seed data" do
    before(:each) do
      @team = Team.new(@attr)
      @team.set_cycle_seed :date => Date.today, :day_in_cycle => 1
    end

    it "should raise an error with invalid arguments" do
      expect { @Team.day_of_cycle?('caca') }.to raise_error
    end

    it "should return proper cycle day" do
      inputs = [Date.today, Date.today-12, Date.today-4, Date.today+1, Date.today+6, Date.today+24+1, Date.today+4]
      targets = ['M1', 'M1', 'N', 'J', 'M2', 'J', false]

      @team.day_of_cycle?.should eql('M1') # A call without argument should default to today

      inputs.each_with_index do |v,k|
        @team.day_of_cycle?(v).should eql(targets[k])
      end
    end
  end
end
