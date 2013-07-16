require 'spec_helper'

describe SingleEvent do

  describe "single instance behaviour" do
    before(:each) do
      @attr = { 
        :name => "Event",
        :user => FactoryGirl.create(:user),
        :starttime => Time.now.beginning_of_day + 2.hours,
        :endtime => Time.now.beginning_of_day + 5.hours,
        :all_day => false,
        :description => "Description of the event"
      }
    end

    it "should create a new instance given a valid attribute" do
      SingleEvent.create!(@attr)
    end

    describe "required fields" do
      fields = [:name, :starttime, :endtime, :all_day]
      
      fields.each do |f|
        it "should require a #{f.to_s}" do
          no_X = SingleEvent.new(@attr.merge(f => ""))
          no_X.should_not be_valid
        end
      end
    end

    it "should reject invalid user" do
      t = [nil]
      t.each do |t|
        invalid = SingleEvent.new(@attr.merge(:user => t))
        invalid.should_not be_valid
      end
    end

    it "should be destroyed if parent is destroyed" do
      parent = @attr[:user]
      child = SingleEvent.create(@attr)
      parent.destroy!
      SingleEvent.all.should_not include(child)
    end

  end

  describe "belonging behaviour" do
    before(:each) do
      @user = FactoryGirl.create(:user_with_single_events)
    end

    describe "scopes" do
      it "should provide before scope" do
        @user.single_events.before(Time.now+15.days).count.should eql(3) # We should have all three events
        @user.single_events.before(Time.now+5.days).count.should eql(2) # Excluse ten_days_after single_event
        @user.single_events.before(Time.now-5.days).count.should eql(1) # Only ten_days_before single_event
        @user.single_events.before(Time.now-15.days).count.should eql(0) # None
      end

      it "should provide after scope" do
        @user.single_events.after(Time.now-15.days).count.should eql(3) # We should have all three events
        @user.single_events.after(Time.now-5.days).count.should eql(2) # Excluse ten_days_after single_event
        @user.single_events.after(Time.now+5.days).count.should eql(1) # Only ten_days_before single_event
        @user.single_events.after(Time.now+15.days).count.should eql(0) # None
      end

      it "should provide day scope" do
        @user.single_events.day(Time.now-10.days).count.should eql(1)
      end

      it "should work with chained scopes" do
        @user.single_events.after(Time.now+1.days).before(Time.now+9.days).count.should eql(0)
        @user.single_events.after(Time.now-1.days).before(Time.now+9.days).count.should eql(1)
        @user.single_events.before(Time.now+1.days).after(Time.now-15.days).count.should eql(2)
      end
    end
  end
end
