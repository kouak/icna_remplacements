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
  def events_for(day)
    raise ArgumentError unless day.is_a? Time
    vacation = team.day_of_cycle(day) # Find vacation on this day
    r = single_events.day(day) # Find linked single_events
    r + [single_events.new(
      :name => vacation[:title],
      :starttime => vacation[:when],
      :endtime => vacation[:when],
      :all_day => true
      )
    ]
  end

  def events_between(after, before)
    raise ArgumentError unless after.is_a? Time and before.is_a? Time # sanitize arguments
    raise ArgumentError if after > before # invalid range

    vacation = team.cycle.vacations_between(after, before).map do |x| # Find vacations on this range
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