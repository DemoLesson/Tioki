class VouchesController < ApplicationController
	before_filter :login_required, :only => [:addvouch]

	def vouchrequest
		if params[:skills] == nil || params[:skills].size == '0'
			return redirect_to :back, :notice => "You must choose at least one of your skills to be vouched in."
		end
		user = User.find(:first, :conditions => ["email = ?", params[:vouch][:email]])
		@vouch = Vouch.new(params[:vouch])
		@vouch.vouchee_id= self.current_user.id
		#using a random string + the user_id and vouch_id to create a unique address
		vouchinfo=User.random_string(20)
		if params[:is_teacher] == nil || params[:is_teacher] == '0' 
			#Just request email
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s )
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email],url).deliver
				redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		elsif user != nil
			#Send a vouch request email
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				if params[:skills_for_teacher]
					params[:skills_for_teacher].each do |skill|
						VouchedSkill.create(:user_id => user.id, :skill_id => skill, :voucher_id => User.current.id)
					end
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s)
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email],url).deliver
				redirect_to '/profile/'+User.current.teacher.url
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		else
			#Person is teacher without an account with demolesson
			@vouch.for_new_educator = true
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				if params[:skills_for_teacher]
					params[:skills_for_teacher].each do |skill|
						ReturnedSkill.create(:vouch_id => @vouch.id, :skill_id => skill)
					end
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s)
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email], url).deliver
				redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		end
	end

	def addvouch
		# Unauthorized if you are trying to vouch your own skill
		raise HTTPStatus::Unauthorized if params[:user_id] == User.current.id

		# Have you already vouched for this skill?
		vouched_skill = VouchedSkill.find(:first, :conditions => ['skill_id = ? && voucher_id = ? && user_id = ?', params[:skill_id], User.current.id, params[:user_id]])

		# Already vouched
		return redirect_to :back, :notice => "You have already vouched for this skill" if vouched_skill
		
		# Create a new vouch
		vouch = VouchedSkill.create(:skill_id => params[:skill_id], :user_id => params[:user_id], :voucher_id => User.current.id)

		#Inform vouchee of the vouch five minutes later to give time for voucher to add more vouches
		#first search for existing
		user_delayed_job = UserDelayedJob.find(:first, :conditions =>["user_id = ? && vouchee_id = ?", User.current.id, params[:user_id]])

		if user_delayed_job
			prev_delayed_job = Delayed::Job.find_by_id(user_delayed_job.delayed_job_id)

			#check if previous job exists and delete as we are going to create a new one
			if prev_delayed_job
				prev_delayed_job.destroy
			else
				#user_delayed_job is invalid
				#needs new time
				user_delayed_job.action_start = vouch.created_at
			end
		else
			user_delayed_job = UserDelayedJob.new(:user_id => User.current.id, :vouchee_id => params[:user_id], :action_start => vouch.created_at)
		end

		delayed_job= UserMailer.delay({:run_at => 3.minutes.from_now}).skills_vouched(params[:user_id], User.current.id, user_delayed_job.action_start)

		user_delayed_job.delayed_job_id = delayed_job.id

		user_delayed_job.save

		# Log to whiteboard and analytics
		Whiteboard.createActivity(:created_vouch, "{user.teacher.profile_link} vouched for {tag.teacher.profile_link} skills.", User.find(params[:user_id]))
		self.log_analytic(:created_vouch, "A user vouched for somones skills.", vouch)

		# Redirect to where you came from
		redirect_to :back
	end

	def updatevouch
		@vouch=Vouch.find(:last, :conditions => ["url = ?", params[:url]])
		user = User.find(:first, :conditions => ["users.email = ?", @vouch.email])
		params[:skills].each do |skill|
			if user
				VouchedSkill.create(:user_id=> @vouch.vouchee_id, :skill_id => skill, :vouch_id => @vouch.id, :voucher_id => user.id)
			else
				VouchedSkill.create(:user_id=> @vouch.vouchee_id, :skill_id => skill, :vouch_id => @vouch.id)
			end
		end
		@vouch.update_attribute(:pending, false)
		if @vouch.for_new_educator == true
			redirect_to "/welcome_wizard?x=step1&vouchstring=#{@vouch.url}", :notice => "Success"
		else
			redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
		end
	end

	def vouchresponse
		@vouch = Vouch.find(:first, :conditions =>["url = ?", params[:u]])
	end

	def unlocked
		# Get a user by looking for the email
		@user = User.find(:first, :conditions => ['email = ?', params[:user][:email]])

		# If the user exists and GET ?urlstring does exist
		if @user != nil && params[:urlstring] != nil

			# If the user has a teacher
			if @user.teacher != nil

				# Find the vouch matching the urlstring
				@vouch = Vouch.find(:first, :conditions => ['url = ?', params[:urlstring]])

				# For the the (new?) teacher loop through the skills
				@vouch.returned_skills.each do |skill|

					# Create a vouched skill for each skill in the loop and attach it to the user
					VouchedSkill.create(:user_id => @user.id, :skill_id => skill.skill_id)
				end
				redirect_to "/card/#{@vouch.user.teacher.url}", :notice => "An account with that email already exists."
			else
				redirect_to "/card/#{@vouch.user.teacher.url}", :notice => "An account with that email already exists."
			end
			# If the user does exist and GET ?invitestring does exist
		elsif @user != nil && params[:invitestring] != nil

			# If the user has a teacher
			if @user.teacher != nil

				# Get the invite by the invitestring
				@invite = ConnectionInvite.find(:first, :conditions => ['url = ?', params[:invitestring]])

				# If no longer pending simply don't create any connections
				if @invite.pending

					# Create two connections
					Connection.create(:owned_by => @user.id, :user_id => @invite.user_id, :pending => false)
					Connection.create(:owned_by => @invite.user_id, :user_id => @user.id, :pending => false)

					# Create two activity logs
					#Activity.create(:creator_id => @connection.user_id, :user_id => @connection.owned_by, :activityType => 10)
					#Activity.create(:creator_id => @connection.owned_by, :user_id => @connection.user_id, :activityType => 10)

					# Insert whiteboard log here
					# Requires a logged in user though

					# Set the invite to completed
					@invite.update_attribute(:pending, false)

					# Redirect to the new users card url
					redirect_to '/card/'+ @user.teacher.url
				end
			end

			# There is already an account with this email
			# WAIT! If the above two conditions in this chain also require a user to exist.
			# Possible security hole?
		elsif @user != nil
			redirect_to :back, :notice => "There is already an account with this email address."

			# If no user exists
		else
			# Generate a random string (For a password)
			password = User.random_string(10)
			params[:user][:password] = password
			params[:user][:confirm_password] = password

			# Generate a new user with the random password
			@user = User.new(params[:user])

			# If the user saved
			if @user.save

				# Create a teacher on the user
				@user.create_teacher

				# Send out the teacher welcome email with the temp password
				UserMailer.teacher_welcome_email_temppassword(@user.id, password).deliver

				# Authenticate the user and set it to the session
				session[:user] = User.authenticate(@user.email, @user.password)

				# If urlstring was provided
				if params[:urlstring]

					# Fild a vouch matching urlstring
					@vouch=Vouch.find(:first, :conditions => ['url = ?', params[:urlstring]])

					# Loop through the skills attached to the vouch
					@vouch.returned_skills.each do |skill|

						@skill=Skill.find(skill.skill_id)
						SkillClaim.create(:user_id => @user.id, :skill_id => skill.skill_id, :skill_group_id => @skill.skill_group_id)
						VouchedSkill.create(:user_id => @user.id, :skill_id => skill.skill_id)
					end

					session[:_ak] = "unlock_vouches"
					redirect_to "/welcome_wizard?x=step2"

					# If invitestring was provided
				elsif params[:invitestring]

					# Find the invite
					@invite=ConnectionInvite.find(:first, :conditions => ['url = ?', params[:invitestring]])

					# If no longer pending simply don't create any connections
					if @invite.pending

						# Create two connections
						Connection.create(:owned_by => @user.id, :user_id => @invite.user_id, :pending => false)
						Connection.create(:owned_by => @invite.user_id, :user_id => @user.id, :pending => false)

						# Create two activities
						#Activity. create(:creator_id => @invite.user_id, :user_id => @user.id, :activityType => 10)
						#Activity.create(:creator_id => @user.id, :user_id => @invite.user_id, :activityType => 10)

						# Put in the whiteboard insert here

						# Set the invite to no longer pending
						@invite.update_attribute(:pending, false)

						# Redirect to the users card profile
						session[:_ak] = "unlock_external_email"
						redirect_to "/welcome_wizard?x=step2"
					end

					# If user_connection is provided attemp to make the connection
				elsif params[:user_connection]

					# Redirect to the connection handler
					redirect_to :controller => :connections, :action => :add_connection, :user_id => params[:user_connection], :to_wizard => true
				else

					# Redirect to the card profile
					session[:_ak] = "unlock"
					redirect_to "/welcome_wizard?x=step2"
				end
			else 

				# Redirect to the last visited page and show all the errors
				redirect_to :back, :notice => @user.errors.full_messages.to_sentence
			end
		end
	end
end
