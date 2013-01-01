desc "Upgrade the notifications."
task :upgrade_notifications => :environment do
	Notification.all.each do |n|
		n.message
		n.link
	end
end