class EventMailer < ActionMailer::Base
  default :from => "Demo Lesson <demolesson@demolesson.com>"

  def approved(user, event)
  	
  	# If the user has opted out of receiving these emails then don't send them
  	return unless user.emaileventapproved

  	@event = event

  	# Since this will be triggered by an admin event lets put this in the users timezone
	start_time = event.start_time.strftime!("%m/%d/%Y %l:%M%P", user.time_zone)

	@message = "Hi #{user.first_name},\n\nWe wanted to let you know that your event \"#{event.name}\" was approved."
	mail(:to => user.email, :subject => "Event Approval Notice")
  end

  def notification(user, event)
	@event = event

	# Since this runs on a Cron Job we want to put the event in the users timezone
	start_time = event.start_time.strftime!("%m/%d/%Y %l:%M%P", user.time_zone)

	@message = "Hi #{user.first_name},\n\nWe wanted to remind you to that an event you RSVPed to is tomorrow. The event details are.\n\n#{event.name} at #{start_time}."
	mail(:to => user.email, :subject => "Event Reminder")
  end
end
