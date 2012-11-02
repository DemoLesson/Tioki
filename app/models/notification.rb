class Notification < ActiveRecord::Base
	belongs_to :user

	def map_tag
		mapTag!(self.notifiable_type)
	end

	def self.notify_likes_comment
		#find users with notifications that have happened in the last hour
		User.find(:all, :include => :notifications, :conditions => ["notifications.created_at > ?", 1.hour.ago]).each do |user|

			notifications = user.notifications.where("created_at > ?", 1.hour.ago)

			liked_notifications = notifications.where("notifiable_type like 'Favorite%'")

			#send an email out for each whiteboard with likes
			favs = liked_notifications.collect { |notification| notification.map_tag }

			#favorite.model is getting nil the first time
			whiteboard_ids = favs.collect { |favorite| favorite.favorited_id }

			Whiteboard.find(:all, :conditions => ["whiteboards.id in (?)", whiteboard_ids])

			whiteboards.each do |whiteboard|
				favorites = Favorite.find(:all, :conditions => ["favorites.model = ?", "#{whiteboard.class.name}:#{whiteboard.id}"])
				if favorites.count > 1
					NotificationMailer.likes(user, favorites)
				elsif count == 1
					NotificationMailer.like(user, favorites.first)
				end
@url 			end
		end
		#For now use delayed_job, however its probably better to use a cron job
		#as this is going to be done on a hourly basis
	end

	def self.notify_discussions
		Discussion.all.each do |discussion|
			comments = discussion.comment_threads.where("comments.created_at > ? ", 1.hour.ago)

			discussion.following_and_participants.each do |user|
				if comments.count > 1
					NotificationMailer.comments(user, comments, discussion).deliver
				elsif comments.count == 1
					NotificationMailer.comment(user, comments.first, discussion).deliver
				end
			end
		end
		#recursively crate this job
		#Should probably use a cron job instead of doing it this way
		Notification.delay({:run_at => 1.hour.from_now}).notify_discussions
	end
end
