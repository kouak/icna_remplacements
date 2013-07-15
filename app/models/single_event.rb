class SingleEvent < ActiveRecord::Base
  belongs_to :user

  validates :name, :presence => true
  validates_presence_of :user
  validates_associated :user
  validates :all_day, :inclusion => {:in => [true, false]}
  validates_datetime :starttime
  validates_datetime :endtime

  scope :before, lambda {|endtime| where("endtime < ?", endtime.to_datetime)}
  scope :after, lambda {|starttime| where("starttime > ?", starttime.to_datetime)}

  def as_json(options={})
    { 
      :title => name,
      :start => starttime.rfc822,
      :end => endtime.rfc822,
      :allDay => all_day,
      :description => description
    }
  end
end
