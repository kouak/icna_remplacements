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
    @cycle ||= Cycle.new(:first_day => self.first_day_in_cycle)
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
    remove_instance_variable :@cycle # Clean up Cycle so it can be refreshed
    self
  end

  # Wrapper for Cycle model method vacation_on
  def day_of_cycle(day = Time.zone.now)
    cycle.vacation_on(day)
  end

  # Returns teams which could replace a member of our own on a specific day
  def who_can_replace_on(day = Time.zone.now)
    raise ArgumentError unless day.is_a? Time
    # First, grab day on the cycle on day
    vacation = cycle.vacation_on(day)
    raise ArgumentError unless vacation[:work] == true # What's the point of calling this method on a day we don't work on ?
    team_numbers = vacation[:who_can_replace].map{|x| self.offset_to_team_number(x)} # compute team numbers
    Team.where(:team => team_numbers)
  end

  # Acts like a modulo
  # eg: We are team 12, offset_to_team_number(+1) will return 1
  def offset_to_team_number(offset)
    base = self.team.to_i
    # TODO: Total equipes should be computed somehow
    total_equipes = 12
    offset = offset % total_equipes
    ((base-1)+offset).modulo(total_equipes) + 1
  end
end