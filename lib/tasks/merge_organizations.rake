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

	School.where("`migrated` IS NULL").each do |school|
		puts "Migrated Org: #{school.name}\n"

		permissions = BitSwitch.new(0, APP_CONFIG['bitswitches']['group_permissions'])
		permissions['organization'] = 1
		permissions['private'] = 1
		permissions['hidden'] = 1

		organization = Hash.new
		organization[:permissions] = permissions
		organization[:name] = school.name
		organization[:description] = school.description
		organization[:long_description] = school.description

		organization = Group.create(organization)
		organization.picture_from_url school.picture.url
		organization.social = {
			:website => school.website,
			:greatschools => school.greatschools,
			:linkedin => school.linkedin,
			:facebook => school.facebook,
			:twitter => school.twitter,
			school.additionallinkname.nil? ? 'tmp' : school.additionallinkname.to_sym => school.additionallinkname.nil? ? nil : school.additionallink
		}
		organization.location = {
			:location => school.location,
			:latitude => school.latitude,
			:longitude => school.longitude,
			:address => school.map_address,
			:city => school.map_city,
			:region => states[school.map_state],
			:postal => school.map_zip
		}
		organization.contact = {
			:phone => school.phone,
			:fax => school.fax
		}
		organization.save!

		# Migrate Jobs
		schools.jobs.each do |job|
			job.group_id = organization.id
			job.save!
		end

		# First User
		userPermissions = BitSwitch.new(0, APP_CONFIG['bitswitches']['user_group_permissions'])
		userPermissions['member'] = 1
		userPermissions['moderator'] = 1
		userPermissions['administrator'] = 1
		userPermissions['owner'] = 1

		User_Group.create(:user_id => school.owned_by, :group_id => organization.id, :permissions => userPermissions)
	end
end
