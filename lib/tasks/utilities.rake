desc "Make sure every user has a slug."
task :normalize => :environment do
	User.unscoped.all.each do |user|

		# Normalizing
		puts "Normalizing User:#{user.id} (#{user.name})"

		# Get the name associated with the user
		string = (("#{user.first_name} #{user.last_name}").strip || "#{user.name}").downcase.squeeze(' ')

		# Split on
		splits = ['mc','\'','-',' ']

		# Properly Capitalize
		splits = splits.collect{|x|(0..string.length-1).find_all{|i|string[i,x.length]==x}.collect{|i|i+x.length}}.flatten.uniq.<<(0).sort{|a,b|b<=>a}
		fibers = splits.collect{|x|string.slice!(x..-1)}
		string = fibers.collect{|x|x.capitalize}.reverse.join

		# Prepare saving users
		user.slug = "#{user.id}#{string}".parameterize if user.slug.nil? || user.slug.empty?
		user.first_name = (names = string.split(' ')).first
		user.last_name = names.last
		user.name = string

		# Save the user
		user.save :validate => false

		# Done
		puts "=> Finished (#{string})"
	end
end

namespace :cron do
	desc "Send all new notifications."
	task :notifications => :environment do
		Notification.notify!
	end

	desc "Send a daily digest."
	task :digest_notifications => :environment do
		Notification.notify!(true)
	end
end