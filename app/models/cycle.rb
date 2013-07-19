class Cycle
  
  include IceCube # Recurring Events

  @@cycle = [ # Default cycle template (class variable)
    {
      :title => 'M1', :work => true, 
      :who_can_replace => [+1, +2, +7, +8],
      :who_can_permute => [-1, +6]
    },
    {
      :title => 'J',  :work => true,
      :who_can_replace => [+2, +3, +8, +9],
      :who_can_permute => [+1, -1, +7, +6]
    },
    {
      :title => 'S1', :work => true,
      :who_can_replace => [+3, +10, +11],
      :who_can_permute => [+5, +6, +7]
    },
    {:title => 'R1', :work => false},
    {:title => 'R2', :work => false},
    {:title => 'R3', :work => false},
    {
      :title => 'M2', :work => true,
      :who_can_replace => [+1, +2, +7, +8],
      :who_can_permute => [-1, +4, +5, +6]
    },
    {
      :title => 'S2', :work => true,
      :who_can_replace => [+3, +4, +9],
      :who_can_permute => [-1, +1, +5, +6]
    },
    {
      :title => 'N',  :work => true,
      :who_can_replace => [+4, +5, +10, +11],
      :who_can_permute => [+1, +6]
    },
    {:title => 'R4', :work => false},
    {:title => 'R5', :work => false},
    {:title => 'R6', :work => false}
  ]

  attr_accessor :cycle # Instance variable


  def initialize(args={})
    raise ArgumentError unless args[:first_day].is_a? Time
    tmp = args[:cycle] || @@cycle # Can provide a custom cycle, .dup to create a new copy
    self.cycle = tmp.dup
    create_schedulers(args[:first_day]) # Create some past vacations
  end

  def to_a
    self.cycle.map { |x| x[:title] }
  end


  # Returns the vacation on a specific day
  def vacation_on(day)
    raise ArgumentError unless day.is_a? Time
    vacations_between(day, day).first
  end

  # Returns an array of vacations based on time stamps
  # OKAY, this is a bit of a mindfuck :
  # Vacations occurs at midnight CEST in Ice Cube (bonus mindfuck points for timezone support ...)
  # after and before usually set based on Time.now
  # We use .beginning_of_day and .end_of_day to properly set the range to make it work as expected
  # Now, if after is 2013-07-16 11:00:00 CEST
  # and if we call this method with before = after + 3.days
  # =>      before is 2013-07-19 11:00:00 CEST
  #
  # default behaviour is to convert after to 2013-07-16 00:00:00 CEST (using beginning_of_day) 
  # and before to 2013-07-19 23:59:59 CEST (using end_of_day)
  # and therefore return vacations on 07-16, 07-17, 07-18 and 07-19
  #
  def vacations_between(after, before, options = {})
    raise ArgumentError unless after.is_a? Time and before.is_a? Time # sanitize arguments
    raise ArgumentError if after > before # invalid range
    vacations_range(after.beginning_of_day, before.end_of_day, options)
  end

  def single_event_on(day)
    single_events_between(day.beginning_of_day, day.end_of_day).first
  end


  def single_events_between(after, before, options = {})
    vacations_between(after, before, options).map do |v| # transform each vacation to single_event
      transform_to_single_event(v)
    end
  end



  protected
  # Assume parameters sanitization has been done before
  # Don't do any in protected methods

  # Transform a vacation to a Single Event
  def transform_to_single_event(v)
    # TODO : Create a Vacation Model to handle all this logic
    SingleEvent.new(
      :name => v[:title],
      :starttime => v[:when].beginning_of_day,
      :endtime => v[:when].end_of_day,
      :all_day => true,
      :override_cycle => true
      )
  end


  # Takes time boundaries as arguments
  # Returns sorted array of vacations happening between given time boundaries
  # options[:work_only] if set to true, will skip non work days (based on cycle[][:work])
  def vacations_range(after, before, options = {})
    # protected method should expect sanitized input from other methods
    results = []
    self.cycle.each do |x| # Loop through all work days
      if options[:work_only] == true and x[:work] == false # Skip non work days if that's what we want
        next
      end
      x[:schedule].occurrences_between(after, before).each do |o|
        results.push({
          :title => x[:title],
          :when => o,
          :work => x[:work],
          :who_can_replace => x[:who_can_replace],
          :who_can_permute => x[:who_can_permute]
        })
      end
    end
    results.sort { |x,y| x[:when] <=> y[:when] } # Sort this array
  end


  # first_day = data seed for the first day of work cycle
  def create_schedulers(first_day)
    raise ArgumentError unless first_day.is_a? Time
    cycle_length = self.cycle.count # Duration of the total work cycle
    first_day = first_day - cycle_length.days # Go back in time a bit
    i = 0
    self.cycle.map! do |x|
      s = Schedule.new((first_day+i.days).beginning_of_day) # First day of cycle, i = 0
      i += 1
      s.add_recurrence_rule Rule.daily(cycle_length) # Make it occuring every X days
      x.merge :schedule => s
    end # returns new cycle array
  end

end