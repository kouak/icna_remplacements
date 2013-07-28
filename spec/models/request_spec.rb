require 'spec_helper'

describe Request do
  describe "relationships" do
    before(:all) do
      @owner = FactoryGirl.create(:user)
      @request = FactoryGirl.create(:request)
      Team.delete_all # Clean up all database residues
      @teams = []
      for i in 1..12 do
        @teams << FactoryGirl.create(:team_with_today_as_first_day, :team => i, :first_day_in_cycle => Time.zone.now + (i-1).days)
      end
    end

    it "should recognize when an user has made no request" do
      @owner.requests.count.should == 0
    end

    it "should properly associate with owner" do
      @owner.requests << @request
      @owner.requests.count.should == 1
      @request.owner.id.should == @owner.id
    end

    it "should properly associate with possible teams" do
      @request.possible_teams.count.should == 0 # no possible teams associated
      @request.possible_teams << [@teams[0], @teams[2]] # add 2 possible teams
      @request.possible_teams.count.should == 2
      @teams[0].possible_requests.first.id.should == @request.id # Teams should access possible_requests
      @teams[2].possible_requests.first.id.should == @request.id
    end
  end

  describe "validation" do
    it "should validate date properly" do
      date = ['user@foo.com', nil]
      date.each do |t|
        request = FactoryGirl.build(:request, :date => t)
        request.should_not be_valid
      end

      date = [Time.now, Time.now-365, Time.now+450]
      date.each do |t|
        request = FactoryGirl.build(:request, :date => t)
        request.should be_valid
      end
    end

  end
end