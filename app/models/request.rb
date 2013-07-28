class Request < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :possible_teams, :class_name => 'Team' 

  validates_datetime :date
end
