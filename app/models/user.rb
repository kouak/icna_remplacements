class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :team
  has_many :single_events, :dependent => :destroy
  
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
    vacation = self.team.cycle.vacations_between(after, before, options).map do |x| # Find vacations on this range, pass options
      single_events.new(
        :name => x[:title],
        :starttime => x[:when],
        :endtime => x[:when],
        :all_day => true
      )
    end
    single_events.before(before).after(after) + vacation # Find single_events and combine with others stubbed from vacations

  end
end