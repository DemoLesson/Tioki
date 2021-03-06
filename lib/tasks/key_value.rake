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

	desc "Migrate group contact to rails 3.2 key values"
	task :group_contact => :environment do
		Group.all.each do |group|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'contact', "Group:#{group.id}")
			kvpairs.each do |kvpair|
				group.contact[kvpair.key] = kvpair.value
			end
		group.save
		end
	end

	desc "Migrate group misc to rails 3.2 key values"
	task :group_misc => :environment do
		Group.all.each do |group|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'misc', "Group:#{group.id}")
			kvpairs.each do |kvpair|
				group.misc[kvpair.key] = kvpair.value
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

	desc "Migrate user contact to rails 3.2 key values"
	task :user_contact => :environment do
		User.all.each do |user|
			kvpairs = Kvpair.where('kvpairs.namespace = ? and kvpairs.owner = ?', 'contact', "User:#{user.id}")
			kvpairs.each do |kvpair|
				user.contact[kvpair.key] = kvpair.value
			end
			user.save
		end
	end

	desc "Migrating seeking kvpairs to rails 3.2 key values"
	task :user_seeking => :environment do
		User.all.each do |user|
			if user.seeking.count > 0
				job_seeker = JobSeeker.new
				job_seeker.user_id = user.id
				job_seeker.grade_ids = user.seeking.grades
				job_seeker.subject_ids = user.seeking.subjects
				if user.seeking.location == 'any'
					job_seeker.any_location = true
				else
					location, box = user.seeking.location.split(':')
					job_seeker.location = location
					job_seeker.box = box
				end
				job_seeker.school_type = user.seeking.school_type
				job_seeker.save!
			end
		end
	end
end
