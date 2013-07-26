# == Schema Information
#
# Table name: teams
#
#  id                 :integer          not null, primary key
#  team               :integer
#  created_at         :datetime
#  updated_at         :datetime
#  first_day_in_cycle :datetime
#

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

  it "should correctly transform offset to team number" do
    team = FactoryGirl.create(:team, :team => 1) # We are team 1
    team.offset_to_team_number(+1).should eql(2)
    team.offset_to_team_number(0).should eql(1)
    team.offset_to_team_number(11).should eql(12)
    team.offset_to_team_number(-1).should eql(12)

    team = FactoryGirl.create(:team, :team => 11) # We are team 11
    team.offset_to_team_number(+2).should eql(1)
    team.offset_to_team_number(+6).should eql(5)
    team.offset_to_team_number(+24).should eql(11)
  end

  context "with seed data" do
    before(:each) do
      @team = Team.new(@attr)
      @team.set_cycle_seed :date => Time.now-1.day, :day_in_cycle => 2 # J yesterday => S1 today
    end

    it "should raise an error with invalid arguments" do
      expect { @team.day_of_cycle('caca') }.to raise_error(ArgumentError)
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

  context "all teams created and initialized" do
    before(:each) do
      Team.delete_all # Clean up all database residues
      @teams = []
      for i in 1..12 do
        @teams << FactoryGirl.create(:team_with_today_as_first_day, :team => i, :first_day_in_cycle => Time.zone.now + (i-1).days)
      end
    end

    # describe "can_replace_on?" do
    #   it "should raise an exception with wrong arguments" do
    #     # We can't replace ourselves
    #     expect { @teams.first.can_replace_on?(@teams.first, Time.zone.now) }.to raise_error ArgumentError
    #     expect { @teams.first.can_replace_on?(nil, nil)}.to raise_error ArgumentError
    #     expect { @teams.first.can_replace_on?(nil, Time.zone.now)}.to raise_error ArgumentError
    #     expect { @teams.first.can_replace_on?(@teams[1], nil)}.to raise_error ArgumentError
    #   end

    # end

    describe "correct replacement teams" do
      it "should raise an exception with wrong arguments" do
        expect { @teams.first.who_can_replace_on(Time.zone.now + 3.days) }.to raise_error ArgumentError
        expect { @teams.first.who_can_replace_on('caca') }.to raise_error ArgumentError
      end

      it "should be good for M1" do
        results = @teams.first.who_can_replace_on(Time.zone.now) # Who can replace Team 1 on M1 ?
        # We need 4 teams => 2, 3, 8, 9
        results.count.should eql(4)
        # Expect actual Teams as results
        results.each{|e| e.should be_a(Team)}
        # Check we have the right teams
        results.select{|e| e.team == 2}.count.should eql(1)
        results.select{|e| e.team == 3}.count.should eql(1)
        results.select{|e| e.team == 8}.count.should eql(1)
        results.select{|e| e.team == 9}.count.should eql(1)


        results = @teams[10].who_can_replace_on(Time.zone.now+10.days) # Who can replace Team 11 on M1 ?
        # We need 4 teams => 12, 1, 6, 7
        puts results.map{|r| r.team }.to_yaml
        results.count.should eql(4)
        # Expect actual Teams as results
        results.each{|e| e.should be_a(Team)}
        # Check we have the right teams
        results.select{|e| e.team == 12}.count.should eql(1)
        results.select{|e| e.team == 1}.count.should eql(1)
        results.select{|e| e.team == 6}.count.should eql(1)
        results.select{|e| e.team == 7}.count.should eql(1)
      end
    end
    describe "correct permutation teams" do
      it "should raise an exception with wrong arguments" do
        expect { @teams.first.who_can_permute_on(Time.zone.now + 3.days) }.to raise_error ArgumentError
        expect { @teams.first.who_can_permute_on('caca') }.to raise_error ArgumentError
      end

      it "should be good for M1" do
        results = @teams.first.who_can_permute_on(Time.zone.now) # Who can permute with Team 1 on M1 ?
        # We need J and M2 teams => 12, 7
        results.count.should eql(2)
        # Expect actual Teams as results
        results.each{|e| e.should be_a(Team)}
        # Check we have the right teams
        results.select{|e| e.team == 7}.count.should eql(1)
        results.select{|e| e.team == 12}.count.should eql(1)


        results = @teams[10].who_can_permute_on(Time.zone.now+10.days) # Who can permute with Team 11 on M1 ?
        # We need J and M2 teams => 10, 5
        results.count.should eql(2)
        # Expect actual Teams as results
        results.each{|e| e.should be_a(Team)}
        # Check we have the right teams
        results.select{|e| e.team == 10}.count.should eql(1)
        results.select{|e| e.team == 5}.count.should eql(1)
      end
    end
  end
end
