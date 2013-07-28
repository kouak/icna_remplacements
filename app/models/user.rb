# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  team_id                :integer
#  detailed               :boolean          default(FALSE)
#  first_name             :string(255)      default(""), not null
#  surname                :string(255)      default(""), not null
#  name                   :string(255)      default(""), not null
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :team
  has_many :single_events, :dependent => :destroy
  has_many :requests, :dependent => :destroy, :foreign_key => 'owner_id'
  
  validates :name, :presence => true
  validates :first_name, :presence => true
  validates_presence_of :team
  validates_associated :team
  validates :detailed, :inclusion => {:in => [true, false]}
  
  def to_s
    if surname.empty?
      return "#{self.first_name.titleize} #{self.name.upcase}"
    else
      return "#{self.first_name.titleize} \"#{self.surname}\" #{self.name.upcase}"
    end
  end

  # returns all events (Team cycle + single_events) on a day or a timerange
  def all_events_for(day)
    raise ArgumentError unless day.is_a? Time
    all_events_between(day.beginning_of_day, day.end_of_day)
  end

  def all_events_between(after, before)
    events_wrapper(after, before)
  end

  def work_events_for(day)
    raise ArgumentError unless day.is_a? Time
    work_events_between(day.beginning_of_day, day.end_of_day)
  end

  def work_events_between(after, before)
    events_wrapper(after, before, :work_only => true)
  end

  protected
  def events_wrapper(after, before, options = {})
    raise ArgumentError unless after.is_a? Time and before.is_a? Time # sanitize arguments
    raise ArgumentError if after > before # invalid range
    events = self.single_events.before(before).after(after) # Find all single events
    filter = events.select { |e| e[:override_cycle] == true } # Select only those with override_cycle set to true
    vacation = self.team.cycle.vacations_between(after, before, options).map do |x| # Find vacations on this range, pass options
      starttime = x[:when].beginning_of_day
      endtime = x[:when].end_of_day
      SingleEvent.new(
        :name => x[:title],
        :starttime => x[:when].beginning_of_day,
        :endtime => x[:when].end_of_day,
        :all_day => true,
        :user => self
      )
    end
    vacation.reject! do |e| # Reject filtered events
      r = false
      filter.each do |f|
        # Look for records included in filtering events
        # Note : .change(:usec => 0) sets the microsecond parts to 0, this is mandatory because of an unexpected behaviour of ActiveRecord,
        # end_of_day, when saved in database and reloaded after appears to be subjet to rounding issues
        # TODO : report ActiveRecord bug
        if f[:starttime].change(:usec => 0) <= e.starttime.change(:usec => 0) and f[:endtime].change(:usec => 999) >= e.endtime.change(:usec => 999)
          r = true
        end
      end
      r
    end
    events + vacation # Find single_events and combine with others stubbed from vacations
  end
end
