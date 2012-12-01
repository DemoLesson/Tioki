desc "Merge teachers into users."
task :merge_teachers => :environment do
	Teacher.where("`migrated` IS NULL").each do |teacher|
		user = teacher.user

		if user.nil?
			teacher.destroy
			next
		end

		user.social = {
			:linkedin => teacher.linkedin,
			:edmodo => teacher.edmodo,
			:twitter => teacher.twitter,
			:betterlesson => teacher.betterlesson,
			:teachingchannel => teacher.teachingchannel,
			:pinterest => teacher.pinterest,
			:website => teacher.website,
			:blog => teacher.blog
		}
		user.contact = {
			:phone => teacher.phone,
			:email => user.email
		}
		user.seeking = {
			:subject => teacher.seeking_subject,
			:grade => teacher.seeking_grade,
			:location => teacher.seeking_location,
			:move => teacher.willing_to_move
		}
		user.authorizations = {
			:twitter_oauth_token => user.twitter_oauth_token,
			:twitter_oauth_secret => user.twitter_oauth_secret,
			:facebook_access_token => user.facebook_access_token
		}

		# Migrate connection objects
		Experience.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Education.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Video.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Interview.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		GradesTeachers.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Award.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Asset.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Application.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		Presentation.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")

		# M2M Migrations
		SubjectsTeachers.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		SubjectsUsers.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		CredentialsTeachers.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
		CredentialsUsers.update_all("`user_id` = #{user.id}", "`teacher_id` = #{teacher.id}")
	  	
	  	# Migrate tagged objects
	  	Analytic.update_all("`tag` = 'User:#{user.id}'", "`tag` = 'Teacher:#{teacher.id}'")
	  	Whiteboard.update_all("`tag` = 'User:#{user.id}'", "`tag` = 'Teacher:#{teacher.id}'")

	  	# Migrate current job
	  	user.experiences.create({
	  		:company => teacher.school,
	  		:position => teacher.position,
	  		:description => teacher.additional_information,
	  		:current => true
	  	})

	  	# Save!
	  	user.slug = "#{user.id}#{user.first_name}#{user.last_name}"
		user.location = teacher.location
		user.guest_code = teacher.guest_code
		user.headline = teacher.headline
		user.save(:validate => false)

	  	# Update Migration
	  	teacher.update_attribute(:migrated, true)
	end
end