class Team < ActiveRecord::Base
	has_many :users
	
  validates_date :first_day_in_cycle

  def to_s
		self.team.to_s
	end

  def name
    to_s
  end

  # TODO: remove hardcoding
  def cycle
    ['M1', 'J', 'S1', false, false, false, 'M2', 'S2', 'N', false, false, false]
  end

  # Takes a hash as argument
  # :day_in_cycle => 1 for M1, 2 for J etc
  # :date => date for this day
  def set_cycle_seed(args = {})
    day_in_cycle = args[:day_in_cycle] || 1
    date = args[:date]
    # raise an error if arguments are not valid
    raise ArgumentError if !date.is_a?(Date) || cycle[day_in_cycle-1].nil?
    # Set first_day_in_cycle correctly
    self.first_day_in_cycle = date-(day_in_cycle-1)
    # save model
    save!
    self
  end

  def day_of_cycle?(day = Date.today)
    raise ArgumentError unless day.is_a?(Date)
    offset = day - first_day_in_cycle
    cycle[offset % cycle.count]
  end
end