desc "Upgrade the notifications."
task :upgrade_notifications => :environment do
	Notification.unscoped.where(:message => nil).all.each do |n|
		puts n.inspect
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

		n.message
		n.link
	end
end