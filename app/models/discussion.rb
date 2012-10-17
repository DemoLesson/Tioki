class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user
	has_many :followers
	has_many :discussion_tags
	has_many :skills, :through => :discussion_tags

	def participants
	end
end
