class Presentation < ActiveRecord::Base
  belongs_to :teacher # Migration 
  belongs_to :user
end
