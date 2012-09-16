class EventMailer < ActionMailer::Base
  default :from => "Tioki <Tioki@Tioki.com>"

  def approved(user, event)
  	
  	# If the user has opted out of receiving these emails then don't send them
  	return unless user.emaileventapproved

  	@event = event

  	# Since this will be triggered by an admin event lets put this in the users timezone
  	start_time = event.start_time.strftime!("%m/%d/%Y %l:%M%P", user.time_zone)

  	@message = "Hi #{user.first_name},\n\nWe wanted to let you know that your event \"#{event.name}\" was approved."
  	mail = mail(:to => user.email, :subject => "Event Approval Notice")

    if mail.delivery_method.respond_to?('tag')
      mail.delivery_method.tag('event_approved')
    end

    return mail
  end

  def notification(user, event)
  	@event = event

  	# Since this runs on a Cron Job we want to put the event in the users timezone
  	start_time = event.start_time.strftime!("%m/%d/%Y %l:%M%P", user.time_zone)

  	@message = "Hi #{user.first_name},\n\nWe wanted to remind you to that an event you RSVPed to is tomorrow. The event details are.\n\n#{event.name} at #{start_time}."
  	mail = mail(:to => user.email, :subject => "Event Reminder")

    if mail.delivery_method.respond_to?('tag')
      mail.delivery_method.tag('event_notification')
    end

    return mail
  end
end
