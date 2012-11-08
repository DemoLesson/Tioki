class Notification < ActiveRecord::Base
	belongs_to :user

	default_scope where("`notifications`.`notifiable_type` != ?", 0.to_s)

	def map_tag
		mapTag!(self.notifiable_type)
	end

	def self.mine(conds = {})
		user = User.current if conds[:user].nil?
		user = conds[:user] unless conds[:user].nil?
		user = User.find(user) if user.is_a?(Fixnum)

		conds[:order] = 'DESC' if conds[:order].nil?

		query = self.where('`notifications`.`user_id` = ?', user.id)
		query = query.order("`notifications`.`created_at` #{conds[:order]}")
	end

	def self.notify_likes
		#find users with notifications that have happened in the last hour
		User.find(:all, :include => :notifications, :conditions => ["notifications.created_at > ?", 1.hour.ago]).each do |user|

			notifications = user.notifications.where("created_at > ?", 1.hour.ago)

			liked_notifications = notifications.where("notifiable_type like 'Favorite%'")

			#send an email out for each whiteboard with likes
			#model with sup == false is returning nil the first time so using the model attribute
			
			whiteboards = Whiteboard.find(:all, :conditions => ["whiteboards.id in (?)", 
			 liked_notifications.collect { |notification| notification.map_tag.model(sup = true).split(':').last }])

			whiteboards.each do |whiteboard|
				favorites = Favorite.find(:all, :conditions => ["favorites.model = ?", 
					"#{whiteboard.class.name}:#{whiteboard.id}"])

				if favorites.count > 1
					NotificationMailer.likes(user, favorites)
				elsif count == 1
					NotificationMailer.like(user, favorites.first)
				end
			end
		end
	end

	def self.notify_discussions
		Discussion.all.each do |discussion|
			comments = discussion.comment_threads.where("comments.created_at > ? ", 1.hour.ago)

			if comments.size != 0
				discussion.following_and_participants.each do |user|

					#remove comments created by this user
					comments.reject! { |comment| comment.user_id == user.id }

					#email_permissions
					if (discussion.participants.include?(user) && !user.email_permissions["participated_discussion"]) || (discussion.following.include?(user) && !user.email_permissions["following_discussion"])
						if comments.size > 1
							NotificationMailer.comments(user, comments, discussion).deliver
						elsif comments.size == 1
							NotificationMailer.comment(user, comments.first, discussion).deliver
						end
					end
				end
			end
		end
	end

	def self.notify_all
		self.notify_discussions
		#self.notify_likes

		#recursively create this job
		#Should probably use a cron job instead of doing it this way
		Notification.delay({:run_at => 1.hour.from_now}).notify_all
	end

	def triggered
		_class = notifiable_type.split(':').first

		case _class
		when 'Comment'
			return map_tag.user
		when 'Favorite'
			return map_tag.user
		end
	end

	def message
		_class = notifiable_type.split(':').first

		ret = String.new
		case _class
		when 'Comment'
			ret = "#{triggered.teacher.profile_link} replied to a discussion."
		when 'Favorite'
			ret = "#{triggered.teacher.profile_link} favorited a post of yours."
		end	

		ret.html_safe
	end

	def link
		map_tag.link rescue nil
	end
end
