class NotificationMailer < ActionMailer::Base
	default :from => "Tioki <tioki@tioki.com>"

	def comments(user, comments, commentable)
		#currently only discussions

		@user= user
		@type = commentable.class.name
		@comments = comments

		#followed, participated in, or created
		if commentable.user_id == @user.id
			@subtype = ""
		elsif commentable.following.include?(user)
			@subtype = " followed"
		else
			@subtype = " participated in"
		end

		@url = "discussions/#{commentable.id}"

		if comments.size == 2
			@action = "#{@comments.first.user.name} and 1 other commented on your#{@subtype} Discussion"
		else
			@action = "#{@comments.first.user.name} and #{@comments.size-1} others commented on your#{@subtype} Discussion"
		end

		mail = mail(:to => @user.email, :subject => @action)

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("multiple_comments_#{@type.downcase}")
		end

		return mail
	end

	def comment(user, comment, commentable)
		@user = user
		@comment = comment
		@type = commentable.class.name

		if @type == "Discussion"
			#followed, participated in, or created
			if commentable.user_id == @user.id
				@subtype = ""
			elsif commentable.following.include?(user)
				@subtype = " followed"
			else
				@subtype = " participated in"
			end
		end

		if @type == "Discussion"
			@url = "discussions/#{commentable.id}"
			@action = "#{@comment.user.name} commented on your#{@subtype} Discussion"
		elsif @type == "Whiteboard"
			@url = "#whiteboard_comments#{commentable.id}"
			@action = "#{@comment.user.name} commented on your Whiteboard Post"
		end

		mail = mail(:to => @user.email, :subject => @action)

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("one_comment_#{@comment.commentable_type.downcase}")
		end

		return mail
	end

	def likes(user, favorites)
		#Get the ids of the favorites
		@user = user
		@favorites = favorites

		@url = "#whiteboard#{favorites.first.model.id}"

		if favorites.count == 2
			mail = mail(:to => @user.email, :subject => "#{@favorites.first.user.name} and 1 other liked your post")
		else
			mail = mail(:to => @user.email, :subject => "#{@favorites.first.user.name} and #{@favorites.count - 1} others liked your post")
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('multiple_likes_whiteboard')
		end

		return mail
	end

	def like(user, favorite)
		@user = user
		@favorite = favorite

		@url = "#whiteboard#{favorite.model.id}"

		mail = mail(:to => @user.email, :subject => "#{@favorite.user.name} liked your post.")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('one_like_whiteboard')
		end

		return mail
	end

	def default(user, notifications)
		@user = user
		@notifications = notifications

		# Mail the user
		mail = mail :to => user.email, :subject => "While you were away from Tioki."

		# Tag the email with generic mailer
		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('notification_generic_mailer')
		end

		# Return the mailer object
		return mail
	end
end
