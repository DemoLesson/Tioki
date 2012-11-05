desc "Notify users about comments and likes that they have received."
task :notify_likes_comments => :environment do
	Notification.notify_all
end
