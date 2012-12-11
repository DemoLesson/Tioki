desc "Merge all schools into organizations."
task :merge_organizations => :environment do

	states = {
		1 => "Alabama",
		2 => "Alaska",
		3 => "Arizona",
		4 => "Arkansas",
		5 => "California",
		6 => "Colorado",
		7 => "Connecticut",
		8 => "Delaware",
		9 => "Florida",
		10 => "Georgia",
		11 => "Hawaii",
		12 => "Idaho",
		13 => "Illinois",
		14 => "Indiana",
		15 => "Iowa",
		16 => "Kansas",
		17 => "Kentucky",
		18 => "Louisiana",
		19 => "Maine",
		20 => "Maryland",
		21 => "Massachusetts",
		22 => "Michigan",
		23 => "Minnesota",
		24 => "Mississippi",
		25 => "Missouri",
		26 => "Montana",
		27 => "Nebraska",
		28 => "Nevada",
		29 => "New Hampshire",
		30 => "New Jersey",
		31 => "New Mexico",
		32 => "New York",
		33 => "North Carolina",
		34 => "North Dakota",
		35 => "Ohio",
		36 => "Oklahoma",
		37 => "Oregon",
		38 => "Pennsylvania",
		39 => "Rhode Island",
		40 => "South Carolina",
		41 => "South Dakota",
		42 => "Tennessee",
		43 => "Texas",
		44 => "Utah",
		45 => "Vermont",
		46 => "Virginia",
		47 => "Washington",
		48 => "West Virginia",
		49 => "Wisconsin",
		50 => "Wyoming",
		51 => "Washington DC",
	}

	organization_type = {
		1 => "District",
		2 => "Charter",
		3 => "Private",
		4 => "Other"
	}

	organization_grades = {
		1 => "Pre-K",
		2 => "Elementary",
		3 => "Middle",
		4 => "High School",
		5 => "Adult School",
		6 => "Other",
		7 => "K-6",
		8 => "K-8",
		9 => "6-12",
		10 => "12"
	}

	organization_calendar = {
		1 => "Year-Round",
		2 => "Track",
		3 => "Semester",
		4 => "Traditional"
	}

	School.where("`migrated` IS NULL").order('`id` DESC').each do |school|
		puts "Migrated Org: #{school.name}\n"

		# Organization data
		organization = Hash.new
		organization[:name] = school.name
		organization[:description] = school.description.nil? ? '' : school.description
		organization[:long_description] = school.description.nil? ? '' : school.description
		organization[:longitude] = school.longitude
		organization[:latitude] = school.latitude

		# Create organization and permissions
		organization = Group.create(organization)
		permissions = organization.permissions
		permissions[:organization] = 1
		permissions[:private] = 1
		permissions[:hidden] = 1

		# Update permissions attribute
		organization.update_attribute(:permissions, permissions)

		# Download the the image from the school
		begin
			organization.picture_from_url school.picture.url if school.picture?
		rescue
		end

		# Update social attributes
		organization.social = {
			:website => school.website,
			:greatschools => school.greatschools,
			:linkedin => school.linkedin,
			:facebook => school.facebook,
			:twitter => school.twitter,
			school.additionallinkname.nil? ? 'tmp' : school.additionallinkname.to_sym => school.additionallinkname.nil? ? nil : school.additionallink
		}

		# Update location attributes
		organization.location = {
			:location => school.location,
			:latitude => school.latitude,
			:longitude => school.longitude,
			:address => school.map_address,
			:city => school.map_city,
			:region => states[school.map_state],
			:postal => school.map_zip
		}

		# Update the location attributes
		organization.contact = {
			:phone => school.phone,
			:fax => school.fax
		}

		# Update misc
		misc = Hash.new
		misc[:school_type] = organization_type[school.school_type] if !school.school_type.nil?
		misc[:school_calendar] = organization_calendar[school.calendar] if !school.calendar.nil?
		misc[:school_grades] = organization_grades[school.grades] if !school.grades.nil?
		misc[:school_district] = school.district if !school.district.nil? && !school.district.empty?
		misc[:mission] = school.mission if !school.mission.nil? && !school.mission.empty?
		organization.misc = misc

		# Save the organization (Primarily for the image)
		organization.save!

		# Migrate jobs over
		Job.where(:school_id => school.id).each do |job|
			puts "\t=> Migrated: (#{job.id}) #{job.title}"
			job.status = 'running' if job.active
			job.status = 'completed' if !job.active
			job.group_id = organization.id
			job.save!
		end

		# How many active jobs should we give them
		activeJobs = Job.where(:school_id => school.id, :active => true)
			.where('created_at BETWEEN ? AND ?', 60.days.ago, Time.now)
			.order('created_at DESC')
		activeJobsCount = activeJobs.count

		# Don't create a job pack if there are no active jobs
		if activeJobsCount > 0
			activeJobsStart = activeJobs.limit(1).first.created_at

			# Create the job pack
			JobPack.create(
				:group_id => organization.id,
				:jobs => activeJobsCount,
				:expiration => activeJobsStart + 60.days,
				:inception => activeJobsStart,
				:refunded => 0,
				:amount => 0,
				:additional_data => {:migration => true}.to_json)
		end

		# Create first user and permissions
		userGroup = User_Group.create(
			:user_id => school.owned_by,
			:group_id => organization.id)
		userPermissions = userGroup.permissions
		userPermissions[:member] = 1
		userPermissions[:moderator] = 1
		userPermissions[:administrator] = 1
		userPermissions[:owner] = 1

		# Update permissions attribute
		userGroup.update_attribute(:permissions, userPermissions)

		# Mark the school as being migrated
		school.update_attribute(:migrated, true)
	end

	# Update Application Status Format
	Application.all.each do |app|
		next if !app.status.nil? && app.status.length > 3
		puts "Updating Application (#{app.id})"

		if app.booked != nil
			status = "Interview Requested"
		elsif app.status == false
			status = "Application Declined"
		elsif app.viewed == true
			status = "Profile Reviewed"
		else
			status = "Not Reviewed"
		end

		app.update_attribute(:status,  status)
	end

	# Attach applications to interviews
	Interview.all.each do |int|
		puts "Updating Interview (#{int.id})"
		application = int.job.applications.where(:user_id => int.user_id).first
		int.update_attribute(:application_id, application.id) if !application.nil?
	end

	puts "Done!!!!!!"

end
