# == Schema Information
#
# Table name: single_events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  starttime      :datetime
#  endtime        :datetime
#  all_day        :boolean
#  description    :string(255)
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  override_cycle :boolean          default(FALSE)
#

class SingleEvent < ActiveRecord::Base
  belongs_to :user

  validates :name, :presence => true
  validates_presence_of :user
  validates_associated :user
  validates :all_day, :inclusion => {:in => [true, false]}
  validates_datetime :starttime
  validates_datetime :endtime

  scope :before, lambda {|starttime| where("starttime <= ?", starttime.to_time)} # Events STARTING before
  scope :after, lambda {|endtime| where("endtime >= ?", endtime.to_time)} # Events ENDING after
  scope :day, lambda {|day| after(day.to_time.beginning_of_day).before(day.to_time.end_of_day)}

end
