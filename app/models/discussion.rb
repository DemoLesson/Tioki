class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user
	has_many :followers
	has_many :discussion_tags
	has_many :skills, :through => :discussion_tags

	def participants
		self.comment_threads.collect(&:user).unshift(self.user).uniq
	end
end
