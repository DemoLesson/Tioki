class Notification < ActiveRecord::Base
	belongs_to :user

	def map_tag
		mapTag!(self.notifiable_type)
	end

	def type
		notification_tag.split(':').first
	end

	def notifiable_id
		notification_tag.split(':').last
	end
end
