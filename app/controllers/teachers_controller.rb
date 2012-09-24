class TeachersController < ApplicationController
	before_filter :login_required, :except => [:profile, :guest_entry]
	API_KEY, SECRET_KEY = "mgb6uz10qf31", "9WXAkgt6TyPdfJGI"

	# GET /teachers/1
	# GET /teachers/1.json
	def profile

		# If we got a url argument then load that user
		unless params[:url].nil? || params[:url].empty?
			@teacher = Teacher.find_by_url(params[:url])

		# Otherwise load the currently logged in user
		else; unless self.current_user.nil? || self.current_user.teacher.nil?
				@teacher = self.current_user.teacher
		end; end

		# If the teacher could not be found then raise an exception
		raise ActiveRecord::RecordNotFound, "Teacher not found." if @teacher.nil?

		# Log that someone viewed this profile unless there is no teacher associated with the user or you are viewing your own profile
		if !self.current_user.nil? && !self.current_user.teacher.nil? && self.current_user.teacher != @teacher
			self.log_analytic(:view_teacher_profile, "Someone viewed a teacher profile", @teacher)
		end

		# Load up an application
		@application = nil
		if params[:application] != nil
			@application = Application.find(params[:application])
			@application = nil unless @application.belongs_to_me(self.current_user)
		end
		
		
		# If the there is currently a user logged in
		if self.current_user != nil
			@pin = Pin.find(:first, :conditions => ['teacher_id = ? and user_id =?', @teacher.id, self.current_user.id], :limit => 1)
			@star = Star.find(:first, :conditions => ['teacher_id = ? and voter_id = ?', @teacher.id, self.current_user.id], :limit => 1)
			@connection = Connection.find(:first, :conditions => ['owned_by = ? and user_id = ?', self.current_user.id, @teacher.user.id])
			@pendingconnection =  Connection.find(:first, :conditions => ['owned_by = ? and user_id = ? and pending = true', @teacher.user.id, self.current_user.id])
		end

		# Get a list of all the stars
		@stars = Star.find(:all, :conditions => ['teacher_id = ?', @teacher.id])
		
		# Load in viddler config
		@config = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'viddler.yml'))).result)[Rails.env]
		
		# Get the latest video the user posted
		@video = Video.find(:all, :conditions => ['teacher_id = ? AND is_snippet=?', @teacher.id, false], :order => 'created_at DESC')
		@video = @video.first
		
		begin
			if @video.encoded_state == 'queued'
				Zencoder.api_key = 'ebbcf62dc3d33b40a9ac99e623328583'
				@status = Zencoder::Job.progress(@video.job_id)
				if @status.body['outputs'][0]['state'] == 'finished'
					@video.encoded_state = 'finished'
					@video.save
					@embed_code = @teacher.vjs_embed_code(@video.output_url)
				else
					@embed_code = @teacher.no_embed_code
				end
			else 
				@embed_code = @teacher.vjs_embed_code(@video.output_url)
			end
		rescue
			@embed_code = @teacher.no_embed_code
		end

		# Generate Progress Values
		if !self.current_user.nil? && !self.current_user.teacher.nil? && self.current_user.teacher == @teacher
			@progress = 0

			# Image
			@progress += 10 if @teacher.user.avatar?

			# Contact
			@progress += 10 if @teacher.user.email?
			@progress += 10 if @teacher.phone.present?

			# Linkedin
			@progress += 10 if @teacher.linkedin? && @teacher.linkedin != "http://linkedin.com/"

			# Current
			@progress += 5 if @teacher.position.present?
			@progress += 5 if @teacher.school.present?
			@progress += 5 if @teacher.location.present?

			# Seeking
			@progress += 5 if @teacher.seeking_subject.present?
			@progress += 5 if @teacher.seeking_grade.present?
			@progress += 5 if @teacher.seeking_location.present?

			# Video
			@progress += 20 unless @video.nil?
		end

		# Filter Upcoming Events
		@events = @teacher.user.rsvp.select do |x|
			(x.end_time.future? || x.end_time.today?) && x.published
		end

		if @teacher == nil
			redirect_to :root
			flash[:alert]  = "Not found"
		else 
			respond_to do |format|
				format.html # profile.html.erb
				format.json  { render :json => @teacher } # profile.json
			end
		end
	end
	
	# Guest pass
	
	def guest_entry
		guest_pass = params[:guest_pass]
		
		@teacher = Teacher.find_by_guest_code(guest_pass)
		redirect_to '/'+@teacher.url+'/'+guest_pass
	end
	
	# Profile Editing
	
	def education
		@teacher = Teacher.find(self.current_user.teacher.id)
		raise ActiveRecord::RecordNotFound, "Teacher not found." if @teacher.nil?
	end
	
	def remove_education
		@education = Education.find_by_id(params[:id], :limit => 1)
		@education.destroy
		
		respond_to do |format|
			format.html { redirect_to :education }
		end
	end
	
	def edit_education
		@education = Education.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def update_education
		@teacher = Teacher.find(self.current_user.teacher.id)
		@teacher.educations.build(params[:education])
		
		respond_to do |format|
			if @teacher.save
				format.html { redirect_to :education, :notice => "Education details updated." }
			else
				format.html { redirect_to :education, :notice => "An error occurred."}
			end 
		end
	end
	
	def update_existing_education
		@education = Education.find(params[:id])
		
		respond_to do |format|
			if @education.update_attributes(params[:education])
				format.html { redirect_to :education, :notice => "Education details updated." }
			else
				format.html { redirect_to :education, :notice => "An error occurred."}
			end 
		end
	end
	
	def experience
		@teacher = Teacher.find(self.current_user.teacher.id)
		raise ActiveRecord::RecordNotFound, "Teacher not found." if @teacher.nil?
	end
	
	def remove_experience
		@experience = Experience.find_by_id(params[:id], :limit => 1)
		@experience.destroy
		
		respond_to do |format|
			format.html { redirect_to :experience }
		end
	end
	
	def edit_experience
		@experience = Experience.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def update_experience
		@teacher = Teacher.find(self.current_user.teacher.id)
		
		@experience = Experience.new(params[:experience])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]
				if params[:current]
				  @experience.current=true
				else
				  @experience.current=false
				end
		
		@teacher.experiences.build(:company => @experience.company, :position => @experience.position, :description => @experience.description, :startMonth => @experience.startMonth, :startYear => @experience.startYear, :endMonth => @experience.endMonth, :endYear => @experience.endYear, :current => @experience.current)
		
		respond_to do |format|
			if @teacher.save
				format.html { redirect_to :experience, :notice => "Experience details updated." }
			else
				format.html { redirect_to :experience, :notice => "An error occurred."}
			end 
		end
	end
	
	def update_existing_experience
		@prev_experience = Experience.find(params[:id])
		
		@experience = Experience.new(params[:experience])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]
				if params[:current]
				  @experience.current=true
				else
				  @experience.current=false
				end
		
		respond_to do |format|
			if @prev_experience.update_attributes(:company => @experience.company, :position => @experience.position, :description => @experience.description, :startMonth => @experience.startMonth, :startYear => @experience.startYear, :endMonth => @experience.endMonth, :endYear => @experience.endYear, :current => @experience.current)
				format.html { redirect_to :experience, :notice => "Experience details updated." }
			else
				format.html { redirect_to :experience, :notice => "An error occurred."}
			end 
		end
	end
	
	# GET /teachers/1
	# GET /teachers/1.json
	def show
		@teacher = Teacher.find(params[:id])

		respond_to do |format|
			if @teacher.url?
				format.html { redirect_to '/profile/' + self.current_user.teacher.url }
			else
				format.html { redirect_to :create_profile }
			end
		end
	end
	
	def create_profile
		@teacher = Teacher.find(self.current_user.teacher.id)

		respond_to do |format|
			if @teacher.url?
				format.html { redirect_to '/'+self.current_user.teacher.url }
			else
				format.html # show.html.erb
				format.json  { render :json => @teacher }
			end
		end
	end

	# GET /teachers/new
	# GET /teachers/new.json
	def new
		@teacher = Teacher.new

		respond_to do |format|
			format.html # new.html.erb
			format.json  { render :json => @teacher }
		end
	end

	# GET /teachers/1/edit
	def edit
		if User.current.nil? || User.current.teacher.nil?
			return render :json => {"message" => "Nothing"}
		end

		# Get the current teacher
		@teacher = User.current.teacher

		# Get the teachers skills
		@skills = @teacher.skills
		# Get the teachers last video
		@video = @teacher.videos.last
	end

	# POST /teachers
	# POST /teachers.json
	def create
		@teacher = Teacher.new(params[:teacher])
		@teacher.assets.build

		respond_to do |format|
			if @teacher.save
				format.html { redirect_to(@teacher, :notice => 'Teacher was successfully created.') }
				format.json  { render :json => @teacher, :status => :created, :location => @teacher }
			else
				format.html { render :action => "new" }
				format.json  { render :json => @teacher.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /teachers/1
	# PUT /teachers/1.json
	def update
		# Get the teacher
		@teacher = Teacher.find(params[:id])

		# Flash an error if the user if not autorized
		unless @teacher.id == self.current_user.teacher.id
			flash[:error] = "Not authorized"
			redirect_to :root
		end

		respond_to do |format|
			if @teacher.update_attributes(params[:teacher])

				# Make a Whiteboard Post
				Whiteboard.createActivity(:profile_update, "{user.teacher.profile_link} updated their profile.")

				format.html { redirect_to(@teacher, :notice => 'Teacher was successfully updated.') }
				format.json  { head :ok }
			else
				format.html { render :action => "edit" }
				format.json  { render :json => @teacher.errors, :status => :unprocessable_entity }
			end
		end
	end
	
	# Attachments
	#REFACTOR

	def attach
		@teacher = Teacher.find_by_id(self.current_user.teacher.id)
		@teacher.new_asset_attributes=params[:asset]

		respond_to do |format|
			if @teacher.save_assets
				format.html { redirect_to(@teacher, :notice => 'Attachment was successfully uploaded.') }
				format.json  { render :json => @teacher, :status => :created, :location => @teacher }
			else
				format.html { render :action => "new" }
				format.json  { render :json => @teacher.errors, :status => :unprocessable_entity }
			end
		end
	end
	
	def purge
		@teacher = Teacher.find_by_id(self.current_user.teacher.id)
		@asset = Asset.find_by_id(params[:id])
		if @asset.teacher_id == self.current_user.teacher.id
			@asset.destroy
		
			respond_to do |format|
			 format.html { redirect_to(:back, :notice => 'Attachment removed.') }
			 format.xml  { head :ok }
			end
		end
	end
	
	# Actions (AJAXify + REFACTOR)
	
	def add_pin
		@pin = Pin.new
		@pin.user_id = self.current_user.id
		@pin.teacher_id = params[:teacher_id]
		
		# warning add duplicate check here
		
		if (request.xhr?)
			if @pin.save 
				render :text => "Pinned!"
			end
		else
				# No?  Then render an action.
				if @pin.save 
					respond_to do |format|
						format.html { redirect_to :root }
					end
				end
		end
	end
	
	def remove_pin
		@pin = Pin.find_by_teacher_id(params[:teacher_id], :limit => 1)
		@pin.destroy
		
		respond_to do |format|
			format.html { redirect_to :root }
		end
	end
	
	def add_star
		@star = Star.new
		@star.teacher_id = params[:teacher_id]
		@star.voter_id = self.current_user.id
		
		@teacher = Teacher.find(params[:teacher_id])
		
		if @star.save
			respond_to do |format|
				format.html { redirect_to "/"+@teacher.url }
			end
		end
	end
	
	def remove_star
		@star = Star.find(:first, :conditions => ['teacher_id = ? and voter_id = ?', params[:teacher_id], self.current_user.id], :limit => 1)
		@star.destroy
		
		@teacher = Teacher.find(params[:teacher_id])
		
		respond_to do |format|
			format.html { redirect_to "/"+@teacher.url }
		end
	end

	def linkedinprofile
		if request.post?
			if params[:response] == 'yes'
				client = LinkedIn::Client.new(API_KEY, SECRET_KEY)
				#oauth_Callback=where linkedin will redirect back to
				request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/callback")
				session[:rtoken] = request_token.token
				session[:rsecret] = request_token.secret
				redirect_to client.request_token.authorize_url
			elsif params[:response] == 'no'
				redirect_to '/'+self.current_user.teacher.url     
			end
		end
	end

	def callback
		@teacher = Teacher.find(self.current_user.teacher.id)
		client = LinkedIn::Client.new(API_KEY, SECRET_KEY)
		pin = params[:oauth_verifier]
		client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

		#begin populating profile
		#set teacher.linkedin
		user = client.profile(:fields => %w(public-profile-url))
		@teacher.update_attribute(:linkedin, user.public_profile_url)

		#educations
		user = client.profile(:fields => %w(educations))
		if user.educations.all != nil
			user.educations.all.each do |education|
				school = education.school_name
				degree = education.degree
				concentrations = education.field_of_study
				year = education.end_date.year
				@teacher.educations.build(:school => school, :degree => degree, :concentrations => concentrations, :year => year)
				@teacher.save
			end
		end

		#positions
		user = client.profile(:fields => %w(positions))
		currentposition=nil
		currentschool=nil
		if user.positions.all != nil
			user.positions.all.each do |position|
				company = position.company.name
				positiontitle = position.title
				startMonth = position.start_date.month
				startYear = position.start_date.year
				if position.is_current == true
					endMonth = Time.now.month
					endYear = Time.now.year
					current = true
					if position.company.industry == "Primary/Secondary Education"
						currentposition = position.title
						currentschool = position.company.name
					end
				else
					endMonth = position.end_date.month
					endYear = position.end_date.year
					current = false
				end
				@teacher.experiences.build(:company => company, :position => positiontitle, :startMonth => startMonth, :startYear => startYear, :endMonth => endMonth, :endYear => endYear, :current => current)
				@teacher.save
			end
		end
		if currentschool != nil && currentposition != nil
			@teacher.update_attribute(:school, currentschool)
			@teacher.update_attribute(:position, currentposition)
		end

		#phone number
		user= client.profile(:fields => %w(phone-numbers))
		phone=nil
		if user.phone_numbers.all != nil
			user.phone_numbers.all.each do |number|
				if number.phone_type == "home" || number.phone_type == "mobile"
					phone = number.phone_number
					break
				end
			end
		end
		if phone != nil
			@teacher.update_attribute(:phone, phone)
		end

		#Addtional Information:
		addinfo = ""
		#Interests
		user =client.profile(:fields => %w(interests))
		if user.interests != nil
			addinfo = "Interests: " + user.interests
		end
		#groups and associations
		user =client.profile(:fields => %w(associations))
		if user.associations != nil
			addinfo = addinfo + "\nGroups and Associations: " + user.associations
		end
		#honors
		user =client.profile(:fields => %w(honors))
		if user.honors != nil
			addinfo = addinfo + "\nHonors: " + user.honors
		end
		@teacher.update_attribute(:additional_information, addinfo)

		#Linkedin integration is currently a one time thing so deleting session keys
		#and redirecting to profile like create_profile does
		session[:rtoken]=nil
		session[:rsecret]=nil
		redirect_to '/'+self.current_user.teacher.url     
	end

	def favorites
		@pins = Pin.paginate(:page=> params[:page], :conditions => [ 'user_id = ?', self.current_user.id] )
	end
	
	def teacher_applications
		@featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')
		@interviews = Interview.paginate :conditions => ['teacher_id = ?', self.current_user.teacher.id], :order => 'created_at DESC', :page => params[:interview_page], :per_page => 5
		@applications = Application.paginate :conditions => ['teacher_id = ?', self.current_user.teacher.id], :order => 'created_at DESC', :page => params[:application_page], :per_page => 5
		@pendingcount=Connection.find(:all, :conditions => ['user_id = ? AND pending = true', self.current_user.id]).count  
	end

	def appattachments
		@application = Application.find(params[:id])
		@teacher = Teacher.find(self.current_user.teacher.id)
	end

	def profileattachments
	  @teacher = User.current.teacher
	end

	# Profile stats
	def stats
		
		@pendingcount = self.current_user.pending_connections.count
		# Get the teacher id of the currently logged in user
		@teacher = Teacher.find(self.current_user.teacher.id)

		# Get a listing of who has viewed this teacher (IN ALL TIME)
		@viewed = self.get_analytics(:view_teacher_profile, @teacher, nil, nil, true)

		# Get the dates to run the query by
		tomorrow = Time.now.tomorrow
		lastweek = Time.now.last_week

		# Create an empty private hash
		data = Hash.new

		# Get a listing of who has viewed this teachers profile use a block to further contrain the query
		data['profile_last_week'] = self.get_analytics(:view_teacher_profile, @teacher, lastweek.utc.strftime("%Y-%m-%d"), tomorrow.utc.strftime("%Y-%m-%d"), false) do |a|
			a = a.select('count(date(`created_at`)) as `views_per_day`, unix_timestamp(date(`created_at`)) as `view_on_day`')
			a = a.group('date(`created_at`)')
		end

		# Get a listing of who has viewed this teachers card use a block to further contrain the query
		data['card_last_week'] = self.get_analytics(:view_teacher_card, @teacher, lastweek.utc.strftime("%Y-%m-%d"), tomorrow.utc.strftime("%Y-%m-%d"), false) do |a|
			a = a.select('count(date(`created_at`)) as `views_per_day`, unix_timestamp(date(`created_at`)) as `view_on_day`')
			a = a.group('date(`created_at`)')
		end

		# Create an empty public hash
		@data = Hash.new

		# Loop through the data to graph by
		data.each do |k,s|

			# Parse all the dates
			save_time = nil
			dates = Array.new

			# Loop through the actual query results
			s.each do |x|
				time = Time.at(x.view_on_day)

				# If save time is nil ignore
				unless save_time.nil?
					i = 1

					# Set the last time we had for adjusting
					adjust_time = save_time

					# Create empty days of zero if no days are logged
					while i < (time.to_date - save_time.to_date)

						# Adjust the time forward to the next day
						adjust_time = adjust_time.tomorrow

						# Get the right time in seconds (with the utc offset for the timezone)
						tmp = (adjust_time.to_time.localtime.to_i + adjust_time.to_time.localtime.utc_offset) * 1000

						# Add the date to the array of dates
						dates << "[#{tmp}, 0]"

						# Increase the pointer for the while llop
						i += 1
					end
				end

				# Set save time for any more upcoming loops
				save_time = time

				# Get the right time in seconds of a hit (witht the utc offset for the timezone)
				view_on_day = (time.localtime.to_i + time.localtime.utc_offset) * 1000

				# Add the date to the array of dates
				dates << "[#{view_on_day}, #{x.views_per_day}]"
			end

			# Join the data indo an output array
			@data[k] = dates.join(',')
		end
	end

	def skills
		@teacher = Teacher.find(params[:id])
		@skills = @teacher.skills

		@skills.collect! do |v|
			data = v.serializable_hash
			data["skill_group"] = v.skill_group.name.to_sym
			v = data
		end

		render :json => @skills
	end
	
	def edit_skills
		
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

				# Notice and redirect
				session[:wizard] = true
				flash[:notice] = "Skills Updated"
			else

				# If the user save failed then notice and redirect
				flash[:notice] = @teacher.errors.full_messages.to_sentence
			end
		end

		# Get a list of existing skills
		@existing_skills = teacher_path(self.current_user.teacher) + '/skills'
	end

	def request_vouch
		@teacher = User.current.teacher
		@vouch = Vouch.new
	end
end
