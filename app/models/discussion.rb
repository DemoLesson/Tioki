class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user
	has_many :followers
	has_many :skills

	def participants
	end
end
