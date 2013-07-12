class Team < ActiveRecord::Base
	has_many :users
	
	def to_s
		self.team.to_s
	end
end
