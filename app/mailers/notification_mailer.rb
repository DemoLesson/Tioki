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

	def likes
		mail = mail(:to => @user.email, :subject => "#{} and #{} others liked your post")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('multiple_likes')
		end

		return mail
	end

	def like(liker, likee)
		@liker = liker

		mail = mail(:to => @user.email, :subject => '#{} liked your post.')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('one_like')
		end

		return mail
	end
end
