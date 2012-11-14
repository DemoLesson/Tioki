class TeachersController < ApplicationController
	before_filter :login_required, :except => [:profile, :guest_entry]

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

		# Check if user is a guest
		@guest = false; unless params[:guest_pass].nil? || params[:guest_pass].empty?
			@guest = params[:guest_pass].strip == @teacher.guest_code
		end

		# Check if user is connected to teacher or is self
		@self = false; @connected = false
		if !self.current_user.nil? && @teacher == self.current_user.teacher
			@connected = true
			@self = true
		elsif !self.current_user.nil? && self.current_user.connections.collect(&:user_id).include?(@teacher.user_id)
			@connected = true
		end

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
		@video = @teacher.video
		
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
		redirect_to '/profile/' + @teacher.url + '/' + guest_pass
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

	def feature_video
		self.current_user.teacher.update_attribute(:video_id, params[:id])
		redirect_to :back
	end

	def tioki_bucks
		@start_count  = 0
		@tioki_bucks = 0

		#3 connections
		if Connection.mine(:pending => false).count >= 5
			@connected = true
			@start_count += 1
		end

		#follow three discussions
		if Follower.find(:all, :conditions => ["user_id = ?", self.current_user.id]).count >= 3
			@followed = true
			@start_count += 1
		end

		#Join three groups
		if User_Group.find(:all, 
				:conditions => ["user_id = ?", self.current_user.id]).count >= 3
			@groups = true
			@start_count += 1
		end

		#Vouch 5 skills
		if VouchedSkill.find(:all, 
				:conditions => ["voucher_id = ?" , self.current_user.id]).count >= 5
			@vouched_skills = true
			@start_count += 1
		end

		#post to whiteboard
		if Whiteboard.find(:first, 
				:conditions => ["whiteboards.slug = ?", 'share'])
			@whiteboard_post = true
			@start_count += 1
		end

		#Post a reply to discussion
		if Comment.find(:first, :conditions => ["commentable_type = 'Discussion' && comments.user_id = ?", self.current_user.id])
			@commented = true
			@start_count += 1
		end

		#require a date fot his one, ccureently there is not avatar_created_at
		#we could create one, but it would be just one more thing to update on avatar creation
		if self.current_user.avatar?
			@avatar = true
			@start_count += 1
		end

		#referrals
		@invite_count = ConnectionInvite.find(:all, :conditions => ["user_id = ? && connection_invites.created_at > ?", self.current_user.id, TIOKI_BUCKS_START]).count

		#two dollars per invite maxed at 42 dollars
		if @invite_count*2 > 42
			@tioki_bucks += 42
		else
			@tioki_bucks += @invite_count*2
		end

		if @start_count >= 5
			@tioki_bucks += 5
		end

		if self.current_user.teacher.facebook_connect
			@tioki_bucks += 1
		end
		if self.current_user.teacher.twitter_connect
			@tioki_bucks += 1
		end
		if self.current_user.teacher.tweet_about
			@tioki_bucks += 1
		end
	end

	def linkedinprofile
		if request.post?
			if params[:response] == 'yes'
				client = LinkedIn::Client.new(APP_CONFIG.linkedin.api_key, APP_CONFIG.linkedin.app_secret)
				#oauth_Callback=where linkedin will redirect back to
				request_token = client.request_token(:oauth_callback => "http://#{request.host_with_port}/linkedin_callback")
				session[:rtoken] = request_token.token
				session[:rsecret] = request_token.secret
				redirect_to client.request_token.authorize_url
			elsif params[:response] == 'no'
				redirect_to '/profile/'+self.current_user.teacher.url
			end
		end
	end

	def get_started
		@tioki_bucks = 0

		#3 connections
		@connections = Connection.mine(:pending => false).count

		#follow three discussions
		@following = Follower.find(:all, :conditions => ["user_id = ?", self.current_user.id]).count

		#Join three groups
		@groups = User_Group.find(:all, :conditions => ["user_id = ?", self.current_user.id]).count

		#Vouch 5 skills
		@vouched_skills =  VouchedSkill.find(:all, :conditions => ["voucher_id = ?" , self.current_user.id]).count

		#post to whiteboard
		@whiteboard_post =  Whiteboard.find(:first, :conditions => ["user_id = ? && whiteboards.slug = ?", self.current_user.id, 'share'])

		#Post a reply to discussion
		@comment =  Comment.find(:first, :conditions => ["commentable_type = 'Discussion' && comments.user_id = ?", self.current_user.id])
	end
end
