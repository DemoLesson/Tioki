desc "Make sure every user has a slug."
task :user_slug => :environment do
	User.all.each do |user|
		user.update_attribute(:slug, "#{user.id}#{user.first_name}#{user.last_name}".parameterize) if user.slug.nil? || user.slug.empty?
	end
end