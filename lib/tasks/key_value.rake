namespace :key_value do
	desc "Migrate group location to rails 3.2 key values"
	task :location => :environment do
		Group.all.each do |group|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'location', "Group:#{group.id}")

			if kvpairs.where('kvpairs.key = ?', 'address').first
				group.location['address'] = kvpairs.where('kvpairs.key = ?', 'address').first.value
			end

			if kvpairs.where('kvpairs.key = ?', 'city').first
				group.location['city'] = kvpairs.where('kvpairs.key = ?', 'city').first.value
			end

			if kvpairs.where('kvpairs.key = ?', 'region').first
				group.location['region'] = kvpairs.where('kvpairs.key = ?', 'region').first.value
			end

			if kvpairs.where('kvpairs.key = ?', 'postal').first
				group.location['postal'] = kvpairs.where('kvpairs.key = ?', 'postal').first.value
			end

			group.save
		end
	end

	desc "Migrate group social to rails 3.2 key values"
	task :group_social => :environment do
		Group.all.each do |group|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'social', "Group:#{group.id}")
			kvpairs.each do |kvpair|
				group.social[kvpair.key] = kvpair.value
			end
			group.save
		end
	end

	desc "Migrate user social to rails 3.2 key values"
	task :user_social => :environment do
		User.all.each do |user|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'social', "User:#{user.id}")
			kvpairs.each do |kvpair|
				user.social[kvpair.key] = kvpair.value
			end
		user.save
		end
	end
end
