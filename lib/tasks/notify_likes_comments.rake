desc "Notify users about comments and likes that they have received."
task :notify_likes_comments => :environment do
	#find users with notifications that have happened in the last hour
	User.find(:all, :include => :notifications, :conditions => ["notification.created_at > ?", Date.now - 1.hour]).each do |user|
		notifications = user.notifications.where("created_at > ?", Time.now-1.hour)
		liked_notifications = notifications.where("notifiable_type like 'Favorite%'")
		whiteboards = liked_notifications.collect { |notification| notification.map_tag.model }
		whiteboards.each do |model|
			count = Favorite.where("`favorites`.`model` = ?", "#{model.class.name}:#{model.id}").count
			if count > 1
				NotificationMailer.likes(user, liked_notifications)
			elsif count == 1
				NotificationMailer.like(user, liked_notifications.first.map_tag)
			end
		end
	end
end
