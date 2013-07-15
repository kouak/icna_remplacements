class SingleEvent < ActiveRecord::Base
  belongs_to :user

  validates :name, :presence => true
  validates_presence_of :user
  validates_associated :user
  validates :all_day, :inclusion => {:in => [true, false]}
  validates_datetime :starttime
  validates_endtime :endtime
end
