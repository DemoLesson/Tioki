namespace :cron do
	desc "Send all new notifications."
	task :notifications => :environment do
		Notification.notify!
	end

	desc "Send a daily digest."
	task :digest_notifications => :environment do
		Notification.notify!(true)
	end

	desc "Send profile view emails"
	task :view_notifications => :environment do
		Notification.profile_views
	end

	desc "Sweep old sessions"
	task :sweep_session => :environment do
		Session.sweep(24.hours)
	end
end
