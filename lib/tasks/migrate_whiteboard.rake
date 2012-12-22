desc "Convert profile_link to link."
task :migrate_whiteboard => :environment do
	Whiteboard.all.each do |w|
		w.update_attribute(:message, w.message.gsub('profile_link', 'link'))
	end
end