require 'spec_helper'

describe Cycle do
  it "should initialize correctly" do
    expect { Cycle.new(:first_day => Time.now) }.not_to raise_error
  end

  it "should raise an error when initialized with wrong output" do
    expect { Cycle.new(:first_day => nil) }.to raise_error(ArgumentError)
  end

  it "should have a proper default cycle" do
    c = Cycle.new(:first_day => Time.now)
    c.cycle.count.should_not eql(0)  
  end

  it "should accept a different seed cycle" do
    i = [
        {:title => 'First', :work => true},
        {:title => 'Second', :work => true},
        {:title => 'Third', :work => false}
    ]
    c = Cycle.new(:first_day => Time.now, :cycle => i)
    a = c.cycle.map { |x| {:title => x[:title] , :work => x[:work]} }
    a.should eql(i)
  end

  context "properly initialized" do
    before :each do
      @seedcycle = [
        {:title => 'First', :work => true},
        {:title => 'Second', :work => true},
        {:title => 'Third', :work => false}
      ]
      @first_day ||= Time.now
      @cycle = Cycle.new(:first_day => @first_day, :cycle => @seedcycle)
    end

    it "should reponds to to_a" do
      @cycle.to_a.should be_a(Array)
    end

    it "should provides the correct work day given a Time" do
      @cycle.vacation_on(@first_day)[:title].should eql('First')
      @cycle.vacation_on(@first_day + 1.day)[:title].should eql('Second')
      @cycle.vacation_on(@first_day + (@seedcycle.count * 3 + 1).days)[:title].should eql('Second')
    end

    describe "vacations_between" do
      it "should properly sanitize arguments" do
        invalid = [
          [nil, nil],
          [nil, @first_day],
          [@first_day, nil],
          [@first_day + 3.days, @first_day]
        ]
        invalid.each do |i|
          expect { @cycle.vacations_between(i[0], i[1]) }.to raise_error(ArgumentError)
        end
      end

      it "should provides an array of vacations provided a time range" do
        # OKAY, this is a bit of a mindfuck :
        # Vacations occurs at midnight CEST in Ice Cube (bonus mindfuck points for timezone support ...)
        # @first_day is set as Time.now, therefore @first_day + 1.day boundary is AFTER "Second" time of happening
        # We use .beginning_of_day and .end_of_day in vacation_between to make it work properly


        # Now, if @first_day is 2013-07-16 11:00:00 CEST
        # =>      @first_day + 1.day is 2013-07-17 11:00:00 CEST
        # =>      @first_day + 3.days is 2013-07-19 11:00:00 CEST
        # vacations_between will convert these to 2013-07-17 00:00:00 CEST and 2013-07-19 23:59:59 CEST
        # and return vacation on 07-17, vacation on 08-18, vacation on 07-19

        r = @cycle.vacations_between(@first_day + 1.day, @first_day + 3.days)
        r.map { |x| x[:title] }.should eql(['Second', 'Third', 'First'])
      end

      it "should properly filter non work days" do
        r = @cycle.vacations_between(@first_day + 1.day, @first_day + 3.days, :work_only => true)
        r.map { |x| x[:title] }.should eql(['Second', 'First'])
      end
      
      describe "conversion to SingleEvent" do
        before(:each) do
          @time = Time.now
          @owner =  FactoryGirl.create(:user)
          @single_event = @owner.team.cycle.single_event_on(@time)
        end

        it "should return a SingleEvent" do
          @single_event.should be_a(SingleEvent)
        end

        it "should return an invalid SingleEvent (missing user_id)" do
          @single_event.should_not be_valid
        end

        it "should validates after user_id is filled" do
          @single_event.user = @owner
          @single_event.should be_valid
        end

        it "should return correct data" do
          @single_event.starttime.should eql(@time.beginning_of_day)
          @single_event.endtime.should eql(@time.end_of_day)
          @single_event.name.should eql(@owner.team.day_of_cycle(@time)[:title])
          @single_event.all_day.should eql(true)
          @single_event.override_cycle.should eql(true)
        end
      end
    end
  end
end
