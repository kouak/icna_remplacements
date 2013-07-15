class SingleEvent < ActiveRecord::Base
  belongs_to :user

  validates :name, :presence => true
  validates_presence_of :user
  validates_associated :user
  validates :all_day, :inclusion => {:in => [true, false]}
  validates_datetime :starttime
  validates_datetime :endtime

  scope :before, lambda {|endtime| where("endtime <= ?", endtime.to_datetime)}
  scope :after, lambda {|starttime| where("starttime >= ?", starttime.to_datetime)}
  scope :day, lambda {|day| after(day.to_datetime).before((day+1).to_datetime)}

end