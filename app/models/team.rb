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
  # :day_in_cycle => 0 for M1, 1 for J etc
  # :date => date for this day
  def set_cycle_seed(args = {})
    day_in_cycle = args[:day_in_cycle] || 0
    date = args[:date]
    # raise an error if arguments are not valid
    raise Error if !date.is_a?(Date) || cycle[day_in_cycle].nil?
    # Set first_day_in_cycle correctly
    self.first_day_in_cycle = date-day_in_cycle
    # save model
    save!
    self
  end
end