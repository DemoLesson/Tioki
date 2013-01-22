class DiscussionMailer < ActionMailer::Base
	default :from => "Tioki <tioki@tioki.com>"
	include MailerHelper

	def new_discussion(user, discussion)

		# Set the sourced variables
		@discussion = discussion
		@user = user

		# Determine the subject line for the email
		@subject = "#{discussion.user.name} started a new discussion on #{discussion.owner.name}"

		# Prepare the message for delivery
		mail = mail(:to => user.email, :subject => @subject)

		# Tag the email for mailgun
		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("new_group_discussion")
		end

		return mail
	end

	def reply(user, comment)

		# Set the sourced variables
		@comment = comment
		@user = user

		# Determine the subject line for the email
		@subject = "#{comment.user.name} replied to \"#{comment.commentable.title}\""

		# Prepare the message for delivery
		mail = mail(:to => user.email, :subject => @subject)

		# Tag the email for mailgun
		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag("discussion_reply")
		end

		return mail
	end
end
