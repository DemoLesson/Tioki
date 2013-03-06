class WelcomeWizardController < ApplicationController
	layout 'wizard'

	def index
		@buri = '/welcome_wizard'
		if params[:invitecode].present?
			@url = "&invitecode=#{params[:invitecode]}"
		elsif params[:vouchstring].present?
			@url = "&vouchstring=#{params[:vouchstring]}"
		elsif params[:user_connection].present?
			@url = "&user_connection=#{params[:user_connection]}"
		elsif params[:welcomecode].present?
			@url = "&user_connection=#{params[:welcomecode]}"
		elsif params[:twittercode].present?
			@url = "&user_connection=#{params[:twittercode]}"
		elsif params[:facebookcode].present?
			@url = "&user_connection=#{params[:facebookcode]}"
		else
			@url = ""
		end

		# Route to other steps/methods
		return self.send(params[:x]) unless params[:x].nil?

		# Make sure the user is not logged in
		unless currentUser.new_record?
			return redirect_to :root
		end
	end

	def step1
		# Make sure the user is not logged in
		unless currentUser.new_record?
			flash[:notice] = "You cannot go to step 1 of the welcome wizard after you have joined the site."
			return redirect_to :root
		end

		#check if account is part of a vouchrequest
		if params[:vouchstring]
			@vouch = Vouch.where('url = ?', params[:vouchstring]).first
			#check if this account was part of a link to invite a user
		elsif params[:invitecode]
			@inviter = User.where('invite_code = ?', params[:invitecode]).first
		elsif params[:welcomecode]
			@inviter = User.where('invite_code = ?', params[:welcomecode]).first
		end

		# Detect post variables
		if request.post?

			# Create a new user
			@user = User.new(params[:user])

			# Attempt to save the user
			if @user.save
				# Authenticate the user
				session[:user] = User.authenticate(@user.email, @user.password)

				if session[:omniauth]
					@user.authentications.create(:provider => session[:omniauth][:provider],
					                             :uid => session[:omniauth][
				end

				#user was came from the attempting to connect from another users profile
				if params[:user_connection]

					return redirect_to :controller => :connections,
									   :action => :add_connection,
									   :user_id => params[:user_connection],
									   :to_wizard => true

				elsif @inviter

					ConnectionInvite.create(
						:user_id => @inviter.id,
						:created_user_id => @user.id)

					Connection.create(
						:owned_by => @inviter.id,
						:user_id => @user.id,
						:pending => false)

				elsif params[:vouchstring]

					# Loop through the skills attached to the vouch
					@vouch.returned_skills.each do |skill|
						VouchedSkill.create(
							:user_id => @user.id, 
							:skill_id => skill.skill_id, 
							:voucher_id => @vouch.vouchee_id)
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
				elsif params[:discussion_follow]
					discussion = Discussion.find(params[:discussion_follow])
					return redirect_to discussion
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

		# Make sure the user is logged in
		if currentUser.new_record?
			flash[:notice] = "You must be logged in to continue in the wizard. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		# Load the teach and update
		@user = self.current_user

		# Detect post variables
		if request.post?

			# Handle Skills
			params[:user].collect! { |k, v| v.split(',').collect { |x| x.to_i } if ['skills'].include?(k) }
			@user.skills = params[:user][:skills].collect { |x| Skill.find(x) }
			params[:user] = params[:user].delete_if { |k, v| v.empty? || v.is_a?(Array) }

			# Save the updates attributes
			@user.update_attributes(params[:user])

			# Clean empty results from the hash
			params.clean!

			# Attempt to save the user
			if @user.save(:validate => false)

				# Wizard Key
				wKey = "welcome_wizard_step2" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

				# And create an analytic
				self.log_analytic(wKey, "User completed step 2 of the welcome wizard.", self.current_user)

				# Notice and redirect
				flash[:notice] = "Step 2 Completed"
				return redirect_to "#{@buri}?x=step3#{@url}"
			else

				# If the user save failed then notice and redirect
				dump flash[:notice] = @user.errors.full_messages.to_sentence
				return redirect_to "#{@buri}?x=step2#{@url}"
			end
		end

		render :step2
	end

	def step3

		# Make sure the user is logged in
		if currentUser.new_record?
			flash[:notice] = "You must be logged in to continue in the wizard. If you believe you received this message in error please contact support."
			return redirect_to :root
		end

		@user = currentUser
		# Detect post variables
		if request.post?
			# Handle Subjects and Grades
			params[:user].collect! { |k, v| v.split(',').collect { |x| x.to_i } if ['grades', 'subjects'].include?(k) }
			if params[:user][:grades]
				@user.grades = params[:user][:grades].collect { |x| Grade.find(x) }
			end
			if params[:user][:subjects]
				@user.subjects = params[:user][:subjects].collect { |x| Subject.find(x) }
			end
			params[:user] = params[:user].delete_if { |k, v| v.empty? || v.is_a?(Array) }
			# Clean empty results from the hash
			params.clean!

			if params[:experience][:position] && params[:experience][:company]
				params[:experience][:current] = true
				@user.experiences.build(params[:experience])
			end

			if params[:education][:school]
				@user.educations.build(params[:education])
			end

			@user.job_seeking = params[:user][:job_seeking] == "yes"

			@user.years_teaching = params[:years_teaching]

			# Attempt to save the user
			if @user.save(:validate => false)

				# Wizard Key
				wKey = "welcome_wizard_step3" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

				# And create an analytic
				self.log_analytic(wKey, "User completed step 3 of the welcome wizard.", self.current_user)

				if @user.job_seeking
					return redirect_to "/jobs/preferences"
				else
					return redirect_to "/get_started"
				end
			else

				# If the user save failed then notice and redirect
				dump flash[:notice] = @user.errors.full_messages.to_sentence
				return redirect_to "#{@buri}?x=step3#{@url}"
			end

		end

		render :step3
	end

	# # # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # #
	# # # # # # # # # # # # # # # # # # # # # #

	def update_aboutme
		if params.has_key?("aboutme")

			@user= self.current_user

			if @user.update_attribute(:headline, params["aboutme"])
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
			contacts=nil; i=0; loop do
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
			:oauth_token => self.current_user.authorizations[:twitter_oauth_token],
			:oauth_token_secret => self.current_user.authorizations[:twitter_oauth_secret]
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

		contacts = {"type" => 'success', "data" => pcontacts}

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
