class Team < ActiveRecord::Base
	has_many :users
	
  validates_date :first_day_in_cycle

  def to_s
		self.team.to_s
	end
end