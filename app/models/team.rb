class Team < ActiveRecord::Base
	has_many :users
	
  validates_datetime :first_day_in_cycle

  def to_s
		team.to_s
	end

  def name
    self.to_s
  end

  def cycle
    # Lazy loading of cycle
    @cycle ||= Cycle.new(:first_day => Time.now)
  end

  # Takes a hash as argument
  # :day_in_cycle => 1 for M1, 2 for J etc
  # :date => Time (instance) for this day
  def set_cycle_seed(args = {})
    day_in_cycle = args[:day_in_cycle] || 1
    date = args[:date]
    # raise an error if arguments are not valid
    raise ArgumentError if !date.is_a?(Time) || cycle.to_a[day_in_cycle-1].nil?
    # Set first_day_in_cycle correctly
    self.first_day_in_cycle = date-(day_in_cycle-1).days
    # save model
    save!
    self
  end

  # Wrapper for Cycle model
  def day_of_cycle(day = Time.now)
    cycle.vacation_on(day)
  end
end