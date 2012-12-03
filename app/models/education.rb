class Education < ActiveRecord::Base
  belongs_to :teacher # Migration
  belongs_to :user
  
  validates_presence_of :school
end
