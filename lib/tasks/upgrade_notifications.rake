desc "Upgrade the notifications."
task :upgrade_notifications => :environment do
	Notification.unscoped.all.each do |n|
		if n.notifiable_type == '0'
			n.destroy
			next
		end

		if n.map_tag.nil?
			n.destroy
			next
		end

		if n.triggered.nil?
			n.destroy
			next
		end

		print n.message
		print ' - '
		print n.link
		print ' - '
		print n.bucket
		print "\n"
	end
end