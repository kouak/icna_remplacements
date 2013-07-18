require 'spec_helper'

describe User do
  
  describe "singleton" do
    before(:each) do
      @attr = { 
        :name => "NOM",
        :first_name => "Prenom",
        :surname => "Surnom",
        :team => FactoryGirl.create(:team),
        :detailed => false,
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
      }
    end
    
    it "should create a new instance given a valid attribute" do
      User.create!(@attr)
    end
    
    
    describe "required fields" do
      fields = [:name, :first_name]
      
      fields.each do |f|
        it "should require a #{f.to_s}" do
          no_X_user = User.new(@attr.merge(f => ""))
          no_X_user.should_not be_valid
        end
      end
    end
    
    it "should combine first name, surname, and name" do
      inputs = [
        # [ first_name, surname, name ]
        [ 'Benjamin', '', 'Beret' ],
        [ 'jean michel', 'cucul', 'jarre'],
        [ 'JEAN-MICHEL', '', 'JARRE']
      ]
      results = []
      
      targets = [
        'Benjamin BERET',
        'Jean Michel "cucul" JARRE',
        'Jean Michel JARRE'
      ]
      
      inputs.each do |i|
        results << User.new(@attr.merge(:first_name => i[0], :surname => i[1], :name => i[2])).to_s
      end
      
      results.should eql(targets)
      
    end
    
    it "should reject invalid team" do
      teams = [nil]
      teams.each do |t|
        invalid_team_user = User.new(@attr.merge(:team => t))
        invalid_team_user.should_not be_valid
      end
    end
    
    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end
    
    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end
    
    it "should reject duplicate email addresses" do
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
    
    it "should reject email addresses identical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
    
    
    it "should require a name" do
      no_email_user = User.new(@attr.merge(:email => ""))
      no_email_user.should_not be_valid
    end
    
    describe "passwords" do

      before(:each) do
        @user = User.new(@attr)
      end

      it "should have a password attribute" do
        @user.should respond_to(:password)
      end

      it "should have a password confirmation attribute" do
        @user.should respond_to(:password_confirmation)
      end
    end
    
    describe "password validations" do

      it "should require a password" do
        User.new(@attr.merge(:password => "", :password_confirmation => "")).
          should_not be_valid
      end

      it "should require a matching password confirmation" do
        User.new(@attr.merge(:password_confirmation => "invalid")).
          should_not be_valid
      end
      
      it "should reject short passwords" do
        short = "a" * 5
        hash = @attr.merge(:password => short, :password_confirmation => short)
        User.new(hash).should_not be_valid
      end
      
    end
    
    describe "password encryption" do
      
      before(:each) do
        @user = User.create!(@attr)
      end
      
      it "should have an encrypted password attribute" do
        @user.should respond_to(:encrypted_password)
      end

      it "should set the encrypted password attribute" do
        @user.encrypted_password.should_not be_blank
      end

    end
  end

  describe "events" do
    before(:each) do
      @user = FactoryGirl.create(:user_with_single_events, :team => FactoryGirl.create(:team_with_today_as_first_day))
      # Days :      -10 # # # # # # # # # N # # # # # # # # # +10
      # SingleEvents: X . . . . . . . . . X Y . . . . . . . . X (X: override_cycle => false / Y: override_cycle => true)
      # WorkDays:     S . . . M S N . . . M J S . . . M S N . .
    end

    it "should return all events (single_events and team cycle)" do
      events = @user.all_events_for Time.zone.now
      events.count.should eql(2) # 2 events (Team M1 + FactoryGirl single_events)
      events.select{|e| e[:name] == 'M1'}.count.should eql(1) # M1
    end

    it "should return events for a time range" do
      events = @user.all_events_between(Time.zone.now.beginning_of_day-10.days, Time.zone.now-9.days)
      events.count.should eql(3) # 3 events (Team S1 + Team R1 + FactoryGirl single_events)
      events.select{|e| e[:name] == 'S1'}.count.should eql(1)
      events.select{|e| e[:name] == 'R1'}.count.should eql(1)
    end

    it "should return filtered events" do
      events = @user.work_events_between(Time.zone.now.beginning_of_day-10.days, Time.zone.now-9.days)
      events.count.should eql(2) # 3 events (Team S1  + FactoryGirl single_events)
      events.select{|e| e[:name] == 'S1'}.count.should eql(1)
      events.select{|e| e[:name] == 'R1'}.count.should eql(0)
    end

    it "should filter out cycle events with override events" do
      events = @user.work_events_for Time.zone.now+1.days
      events.count.should eql(1) # 1 event only, FactoryGirl SingleEvent with override
      events.select{|e| e[:name] == 'Tomorow Override'}.count.should eql(1)
      events.select{|e| e[:name] == 'J'}.count.should eql(0)
    end

  end

end
