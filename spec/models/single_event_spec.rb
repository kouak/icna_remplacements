require 'spec_helper'

describe SingleEvent do
    before(:each) do
    @attr = { 
      :name => "Event",
      :user => FactoryGirl.create(:user),
      :starttime => Date.today,
      :endtime => Date.today,
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

  it "should return fullcalendar understandable json" do
    hash = FactoryGirl.create(:single_event).as_json
    hash.should have_key :title
    hash.should have_key :start
    hash.should have_key :end
    hash.should have_key :allDay
  end
end
