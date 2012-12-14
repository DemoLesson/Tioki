class Review < ActiveRecord::Base
  belongs_to :application
  belongs_to :user, :foreign_key => :reviewer_id
end
