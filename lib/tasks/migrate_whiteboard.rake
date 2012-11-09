desc "Convert shares with images to articles."
task :migrate_whiteboard => :environment do
	Whiteboard.all.each do |w|
		data = ActiveSupport::JSON.decode(w.data)
		unless data['screens'].empty?
			w.update_attribute(:slug, :article) 
			w.update_attribute(:message, w.message.gsub('{user.teacher.profile_link} Shared: ', ''))
		end
		w.update_attribute(:slug, :connection) if w.slug == 'user_connection'
	end
end