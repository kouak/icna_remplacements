class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :team
  has_many :single_events, :dependent => :destroy
  
  validates :name, :presence => true
  validates :first_name, :presence => true
  validates_presence_of :team
  validates_associated :team
  validates :detailed, :inclusion => {:in => [true, false]}
  
  def to_s
    if self.surname.empty?
      return "#{self.first_name.titleize} #{self.name.upcase}"
    else
      return "#{self.first_name.titleize} \"#{self.surname}\" #{self.name.upcase}"
    end
  end
  
end