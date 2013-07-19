# == Schema Information
#
# Table name: single_events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  starttime      :datetime
#  endtime        :datetime
#  all_day        :boolean
#  description    :string(255)
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  override_cycle :boolean          default(FALSE)
#

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
      @time = Time.zone.now
      # Days :      -10 # # # # # # # # # N # # # # # # # # # +10 (N: Now)
      # SingleEvents: X . . . . . . . . . X Y . . . . . . . . X (X: override_cycle => false / Y: override_cycle => true)
      # WorkDays:     S . . . M S N . . . M J S . . . M S N . .
    end

    describe "scopes" do
      it "should provide before scope" do
        @user.single_events.before(@time+15.days).count.should eql(4) # We should have all three events
        @user.single_events.before(@time+5.days).count.should eql(3) # Excluse ten_days_after single_event
        @user.single_events.before(@time-5.days).count.should eql(1) # Only ten_days_before single_event
        @user.single_events.before(@time-15.days).count.should eql(0) # None
      end

      it "should provide after scope" do
        @user.single_events.after(@time-15.days).count.should eql(4) # We should have all three events
        @user.single_events.after(@time-5.days).count.should eql(3) # Excluse ten_days_after single_event
        @user.single_events.after(@time+5.days).count.should eql(1) # Only ten_days_before single_event
        @user.single_events.after(@time+15.days).count.should eql(0) # None
      end

      it "should provide day scope" do
        @user.single_events.day(@time-10.days).count.should eql(1)
      end

      it "should work with chained scopes" do
        @user.single_events.after(@time+2.days).before(@time+9.days).count.should eql(0)
        @user.single_events.after(@time+1.days).before(@time+9.days).count.should eql(1)
        @user.single_events.after(@time-1.days).before(@time+9.days).count.should eql(2)
        @user.single_events.before(@time+1.days).after(@time-15.days).count.should eql(3)
      end
    end
  end
end
