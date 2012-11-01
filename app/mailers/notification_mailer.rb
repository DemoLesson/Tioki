class NotificationMailer < ActionMailer::Base
	default :from => "Tioki <tioki@tioki.com>"

	def comments(user, commentable)
		@user= user

		#Was this created, participanted in, or followed in that order
		@type = commentable.class.name
		if @type == "Discussion"
		end

		mail = mail(:to => @user.email, :subject => '#{} and #{} other commented on your #{@type} Post')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("multiple_comments_#{@type.downcase}")
		end

		return mail
	end

	def comment(user, comment, commentable)
		#Whiteboard only currently
		@user = user
		@comment = comment
		@whiteboard = commentable
		@url = "#whiteboard_comments#{commentable.id}"

		mail = mail(:to => @user.email, :subject => "#{@comment.user.name} commented on your #{@comment.commentable_type} Post")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("one_comment_#{@comment.commentable_type.downcase}")
		end

		return mail
	end

	def likes(user, liked_notifications)
		#Get the ids of the favorites
		favorite_ids = liked_notifications.collect(&:notifiable_id)
		@favorites = Favorite.find(:all, :conditions => ["id in (?)", favorite_ids])


		mail = mail(:to => @user.email, :subject => "#{@favorites.first.user.name} and #{@favorites.count - 1} others liked your post")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('multiple_likes_whiteboard')
		end

		return mail
	end

	def like(user, favorite)
		@user = user
		@favorite = favorite

		@url = "whiteboard#{favorite.model.id}"

		mail = mail(:to => @user.email, :subject => "#{@favorite.user.name} liked your post.")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('one_like_whiteboard')
		end

		return mail
	end
end
