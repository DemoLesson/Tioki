class DiscussionTag < ActiveRecord::Base
	belongs_to :skill
	belongs_to :discussion
end
