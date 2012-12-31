class CronController < ApplicationController

	# Default Cron Hit Point
	def index

		# If a method is specified then run it
		if params.has_key?("method") && self.respond_to?(params[:method])
			self.send(params[:method])
			return render :text => 'Success'
		end

		# Send out all event reminders
		self.eventReminders()

		# Render success
		render :text => 'Success'
	end

	# Event Reminder Helper
	def eventReminders

		# Get the events that are happening tomorrow
		tomorrow = Time.now.tomorrow.zone!("UTC").strftime("%Y-%m-%d")
		@events = Event.where("date(`start_time`) = '#{tomorrow}'").all.select{|x| x.published}

		# Loop through and process each event
		@events.each do |e|

			# Get a list of the members who want notifications
			users = e.rsvp.email_permissions(:event_reminder)

			users.each do |u|
				EventMailer.notification(u, e)
			end
			
		end
	end
end
