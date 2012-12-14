class Pin < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :user
  self.per_page = 5
end
