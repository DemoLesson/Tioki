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

		#vouch referring teacher 
		if params[:invite_id]
			@invite = ConnectionInvite.find(params[:invite_id])
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
		if @asset.teacher_id == User.current.teacher.id
			@asset.destroy

			unless params[:redirect].nil?
				return redirect_to params[:redirect]
			end
		
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

	def feature_video
		self.current_user.teacher.update_attribute(:video_id, params[:id])
		redirect_to :back
	end

	
end
