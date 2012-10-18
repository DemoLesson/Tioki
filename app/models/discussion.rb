class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user

	has_many :followers, :dependent => :destroy
	has_many :following, :through => :followers, :source => :user
	
	has_many :discussion_tags, :dependent => :destroy
	has_many :skills, :through => :discussion_tags

	def participants
		self.comment_threads.collect(&:user).unshift(self.user).uniq
	end
end
