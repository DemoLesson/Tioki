class WelcomeWizardController < ApplicationController
	layout 'wizard'

	def index
		@buri = '/welcome_wizard'
		if params[:invitecode].present?
			@url = "&invitecode=#{params[:invitecode]}"
		elsif params[:vouchstring].present?
			@url = "&vouchstring=#{params[:vouchstring]}"
		elsif params[:invitestring].present?
			@url = "&invitestring=#{params[:invitestring]}"
		elsif params[:user_connection].present?
			@url = "&user_connection=#{params[:user_connection]}"
		elsif params[:welcomecode].present?
			@url = "&user_connection=#{params[:welcomecode]}"
		else
			@url = ""
		end

		# Route to other steps/methods
		return self.send(params[:x]) unless params[:x].nil?

		# Make sure the user is not logged in
		unless self.current_user.nil?
			return redirect_to :root
		end
	end

	def step1
		# Make sure the user is not logged in
		unless self.current_user.nil?
			flash[:notice] = "You cannot go to step 1 of the welcome wizard after you have joined the site."
			return redirect_to :root
		end

		#check if this account is part of a mass invite email
		if params[:invitestring]
			@invite = ConnectionInvite.find(:first, :conditions => ['url = ?', params[:invitestring]])
			if @invite == nil
				params[:invitestring] = nil
			end
		#check if account is part of a vouchrequest
		elsif params[:vouchstring]
			@vouch = Vouch.find(:first, :conditions => ['url = ?', params[:vouchstring]])
			if @vouch == nil
				params[:vouchstring] = nil
			end
		#check if this account was part of a link to invite a user
		elsif params[:invitecode]
			@inviter = User.find(:first, :conditions => ['invite_code = ?', params[:invitecode]])
			if @inviter == nil
				params[:invitecode] = nil
			end
		elsif params[:welcomecode]
			@inviter = User.find(:first, :conditions => ['invite_code = ?', params[:welcomecode]])
			if @inviter == nil
				params[:welcomecode] = nil
			end
		end
		
		# Detect post variables
		if request.post?

			# Create a new user
			@user = User.new(params[:user])
			
			# Attempt to save the user
			if @user.save

				@user.create_teacher

				# Authenticate the user
				session[:user] = User.authenticate(@user.email, @user.password)

				#user was came from the attempting to connect from another users profile
				if params[:user_connection]
					return redirect_to :controller => :connections, :action => :add_connection, :user_id => params[:user_connection], :to_wizard => true
				elsif params[:invitestring]
					#Mass invite emails connections

					@invite = ConnectionInvite.find(:first, :conditions => ['url = ?', params[:invitestring]])

					if @invite.pending
						Connection.create(:owned_by => @user.id, :user_id => @invite.user_id, :pending => false)
						@invite.update_attribute(:created_user_id, @user.id)
						@invite.update_attribute(:pending, false)

						session[:_ak] = "unlock_invite_link"
					end
				elsif params[:invitecode]
					@inviter = User.find(:first, :conditions => ['invite_code = ?', params[:invitecode]])

					ConnectionInvite.create(:user_id => @inviter.id, :created_user_id => @user.id)
					Connection.create(:owned_by => @inviter.id, :user_id => @user.id, :pending => false)

				elsif params[:welcomecode]
					@inviter = User.find(:first, :conditions => ['invite_code = ?', params[:welcomecode]])

					ConnectionInvite.create(:user_id => @inviter.id, :created_user_id => @user.id, :donors_choose => false)
					Connection.create(:owned_by => @inviter.id, :user_id => @user.id, :pending => false)

				elsif params[:vouchstring]
					# Find a vouch matching urlstring
					@vouch=Vouch.find(:first, :conditions => ['url = ?', params[:vouchstring]])
					@vouch.update_attribute(:voucher_id, @user.id)

					# Loop through the skills attached to the vouch
					@vouch.returned_skills.each do |skill|
						VouchedSkill.create(:user_id => @user.id, :skill_id => skill.skill_id, :voucher_id => @vouch.vouchee_id)
					end
					session[:_ak] = "unlock_vouches"
				end

				# Wizard Key
				wKey = "welcome_wizard_step1" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

				# And create an analytic
				self.log_analytic(:user_signup, "New user signed up.", @user)
				self.log_analytic(wKey, "User completed step 1 of the welcome wizard.", @user)

				# Notice and redirect
				flash[:notice] = "Signup successful"
				if params[:discussion_id]
					@discussion = Discussion.find(params[:discussion_id])
					comment = Comment.build_from(@discussion, @user.id, params[:body])
					if comment.save
						return redirect_to @discussion
					else
						return redirect_to @discussion
					end
				else
					return redirect_to "#{@buri}?x=step2#{@url}"
				end
			else

				# If the user save failed then notice and redirect
				flash[:notice] = @user.errors.full_messages.to_sentence
				return redirect_to "#{@buri}?x=step1#{@url}"
			end
		end

		render :step1
	end

	def step2

		# Make sure the user has a teacher if not error
		if self.current_user.nil? || self.current_user.teacher.nil?
			flash[:notice] = "You must be logged in to continue in the wizard and if you are then you need a teacher record. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		# Detect post variables
		if request.post?

			# Load the teach and update
			@teacher = self.current_user.teacher

			# Handle Subjects and Grades
			params[:teacher].collect!{|k,v| v.split(',').collect{|x|x.to_i} if ['subjects','grades'].include?(k)}
			@teacher.subjects = params[:teacher][:subjects].collect{|x| Subject.find(x)}
			@teacher.grades = params[:teacher][:grades].collect{|x| Grade.find(x)}
			params[:teacher] = params[:teacher].delete_if{|k,v| v.empty? || v.is_a?(Array)}

			# Save the updates attributes
			@teacher.update_attributes(params[:teacher])

			# Clean empty results from the hash
			params.clean!

			unless params[:edu].nil? || params[:edu].empty?

				# Build the education data
				@teacher.educations.build(params[:edu])
			end

			unless params[:experience].nil? || params[:experience].empty?

				# Get full date objects for start and end dates
				start_date = params[:date][:exp_start_month] + '/' + params[:date][:exp_start_year]
				start_date = Time.strptime(start_date, "%m/%Y")
				end_date = params[:date][:exp_end_month] + '/' + params[:date][:exp_end_year]
				end_date = Time.strptime(end_date, "%m/%Y")

				# Go ahead and make that months and years again because the db structure is lame
				params[:experience][:startMonth] = start_date.strftime("%m")
				params[:experience][:startYear] = start_date.strftime("%Y")
				params[:experience][:endMonth] = end_date.strftime("%m")
				params[:experience][:endYear] = end_date.strftime("%Y")

				# Build the experience data
				@teacher.experiences.build(params[:experience])
			end
			
			# Attempt to save the user
			if @teacher.save

				# Wizard Key
				wKey = "welcome_wizard_step2" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

				# And create an analytic
				self.log_analytic(wKey, "User completed step 2 of the welcome wizard.", self.current_user)

				# Notice and redirect
				flash[:notice] = "Step 2 Completed"
				return redirect_to "#{@buri}?x=step3#{@url}"
			else

				# If the user save failed then notice and redirect
				dump flash[:notice] = @teacher.errors.full_messages.to_sentence
				return redirect_to "#{@buri}?x=step2#{@url}"
			end
		end

		render :step2
	end

	def step3

		# Make sure the user has a teacher if not error
		if self.current_user.nil? || self.current_user.teacher.nil?
			flash[:notice] = "You must be logged in to continue in the wizard and if you are then you need a teacher record. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		# Detect post variables
		if request.post?

			# Load the teach and update
			@teacher = self.current_user.teacher
			@teacher.user.skills.delete_all
			
			# Install the skills
			skills = Skill.where(:id => params[:skills].split(','))
			skills.each do |skill|
				SkillClaim.create(:user_id => @teacher.user.id, :skill_id => skill.id, :skill_group_id => skill.skill_group_id)
			end

			#dump skills
			@teacher.skills = skills
			
			# Attempt to save the user
			if @teacher.save

				# Wizard Key
				wKey = "welcome_wizard_step3" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

				# And create an analytic
				self.log_analytic(wKey, "User completed step 3 of the welcome wizard.", self.current_user)

				# Notice and redirect
				session[:wizard] = true
				flash[:notice] = "Step 3 Completed"
				return redirect_to "#{@buri}?x=step4#{@url}"
			else

				# If the user save failed then notice and redirect
				flash[:notice] = @teacher.errors.full_messages.to_sentence
				return redirect_to "#{@buri}?x=step3#{@url}"
			end
		end

		# Get a list of existing skills
		@existing_skills = teacher_path(self.current_user.teacher) + '/skills'

		render :step3
	end

	def step4

		# Make sure the user has a teacher if not error
		if self.current_user.nil? || self.current_user.teacher.nil?
			flash[:notice] = "You must be logged in to continue in the wizard and if you are then you need a teacher record. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		# Detect post variables
		if request.post? && !params[:people].nil?

			if params[:twitter]
				client = Twitter::Client.new(
					:oauth_token => self.current_user.twitter_oauth_token,
					:oauth_token_secret => self.current_user.twitter_oauth_secret
				)

				params.people.split(',').each do |twitter_contact|
					client.direct_message_create(twitter_contact.to_i, "I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code} via @tioki")
				end
			else
				# Split people to invite and loop
				params.people.split(',').each do |email|

					# Parse the email to make sure its valid
					email = Mail::Address.new(email.strip)

					# Get the user
					user = User.where({"email" => email.address}).first

					# If the user exists
					unless user.nil?

						# If the email is tied to a school skip
						next if user.teacher.nil?

						# Try and add a connection
						if Connection.add_connect(self.current_user.id, user.id)
							# We don't really neeed to notify the user about this
							# notice << "Your connection request to " + email.address + " has been sent."
						end

						# If the user does not exist
					else
						# Generate the invitation url to be added to the email
						url = "http://#{request.host_with_port}/ww/#{self.current_user.invite_code}"

						# Send out the email
						mail = UserMailer.connection_invite(self.current_user, email, url, params[:message]).deliver

						# Don't bother notifying the user
						# notice << "Your invite to " + demail + " has been sent."

						# Log an analytic
						self.log_analytic(:connection_invite_sent, "User invited people to the site to connect.", @user)
					end
				end
			end
			
			# Wizard Key
			wKey = "welcome_wizard_step4" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

			# And create an analytic
			self.log_analytic(wKey, "User completed step 4 of the welcome wizard.", self.current_user)

			# Notice and redirect
			session[:wizard] = true
			flash[:notice] = "Step 4 Completed"
			return redirect_to "#{@buri}?x=step5#{@url}"
		end

		@user = self.current_user

		render :step4
	end

	def step5

		# Make sure the user has a teacher if not error
		if self.current_user.nil? || self.current_user.teacher.nil?
			flash[:notice] = "You must be logged in to continue in the wizard and if you are then you need a teacher record. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		@user = self.current_user
		@invite = ConnectionInvite.find(:first, :conditions => ["created_user_id = ?", self.current_user.id])

		render :step5
	end	

	# # # # # # # # # # # # # # # # # # # # # #
	 # # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # # #

	def update_aboutme
		if params.has_key?("aboutme")
			@teacher = self.current_user.teacher
			if @teacher.update_attribute(:headline, params["aboutme"])
				data = {"type" => 'success', "message" => 'Saved successfuly'}
			else
				data = {"type" => 'error', "message" => 'There was a problem saving'}
			end
		else
			data = {"type" => 'error', "message" => 'There was not any data passed'}
		end

		render :json => data
	end

	def get_contacts

		if params.has_key?("STEP1")
			params["email"] = self.current_user.email if params[:email].nil?

			data = Hash.new
			data["service"] = false
			data["service"] = "GMAIL" if is_gmail(params["email"])
			data["service"] = "YAHOO" unless /yahoo.com$/.match(params["email"]).nil?
			data["service"] = "AOL" unless /aol.com$/.match(params["email"]).nil?

			return render :json => data
		end

		if params.has_key?("STEP2")
			# Get the cloudsponge API Keys
			csc = APP_CONFIG["cloudsponge"]

			# Load the Cloudsponge Importer
			cloudsponge = Cloudsponge::ContactImporter.new(csc["domainKey"], csc["domainPassword"])
			return render :json => cloudsponge.begin_import(params["service"])
		end

		if params.has_key?("STEP3")
			# Get the cloudsponge API Keys
			csc = APP_CONFIG["cloudsponge"]

			# Load the Cloudsponge Importer
			cloudsponge = Cloudsponge::ContactImporter.new(csc["domainKey"], csc["domainPassword"])

			# Loop until result
			contacts=nil;i=0;loop do
				# Try and get the contacts
				contacts = cloudsponge.get_contacts_raw(params["import_id"]) rescue nil

				# If contacts were received stop
				break unless contacts.nil?

				# If we ran for 10 seconds time out
				break if i >= 20

				# Sleep for half a second
				sleep 1
				i += 1
			end

			# If we never received any contact then display an error
			if contacts.nil?
				contacts = {"type" => 'error', "message" => 'Retrieving contacts timed out.', "data" => Array.new} 
			else
				select = []
				pcontacts = []
				contacts.contacts.each do |c|

					# Clean out empties
					c.clean!

					# If no email next
					next unless c.has_key?('email')

					# Create a new contact
					contact = Hash.new

					# Process name
					name = Array.new
					name << c.first_name unless c.first_name.nil?
					name << c.last_name unless c.last_name.nil?
					name = name.join(' ').strip.split(' ')
					contact.name = name

					# Get all emails
					emails = []; c.email.each do |e|
						unless User.where({"email" => e.address}).first.nil?
							select << e.address
						end
						emails << e.address
					end; contact.emails = emails

					# Append the contact to the array
					select.uniq!
					pcontacts << contact
				end

				contacts = {"type" => 'success', "message" => "Successfully read #{pcontacts.count} contacts", "data" => pcontacts, "selected" => select}
			end

			return render :json => contacts
		end

		return render :json => {}
	end

	def get_twitter_contacts
		client = Twitter::Client.new(
			:oauth_token => self.current_user.twitter_oauth_token,
			:oauth_token_secret => self.current_user.twitter_oauth_secret
		)
		pcontacts = []

		followers = client.follower_ids

		#user lookup
		users = client.users(followers.ids)

		users.each do |twitter_contact|
			contact = Hash.new
			
			contact.name = twitter_contact.name
			contact.id = twitter_contact.id
			contact.picture = twitter_contact.profile_image_url
			contact.screen_name = twitter_contact.screen_name

			pcontacts << contact
		end

		contacts = { "type" => 'success', "data" => pcontacts}

		return render :json => contacts
	end

	def direct_messages_twitter_contacts
		client = Twitter::Client.new(
			:oauth_token => self.current_user.twitter_oauth_token,
			:oauth_token_secret => self.current_user.twitter_oauth_secret
		)

		params[:twitter_friend].each do |contact|
			#contact is screenname
			client.direct_message_create(contact, "Connect with me at tioki.com via @tioki")
		end
	end

	# Catch rails args
	def create(*args)
		self.send('index', *args)
	end
end
