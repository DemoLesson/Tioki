class EventsController < ApplicationController
	before_filter :login_required, :only => [:invite, :rsvp]

	# GET /events
	# GET /events.json
	def index

		# Filtered Events with pagination
		@events = Event.where("`end_time` >= CURDATE()").page(params[:page]).all

		# Unfiltered Events (We don't want pagination for this)
		@_events = Event.all
		# Topics for the select menu and what not
		@topics = Eventtopic.all

		#print params.inspect;
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @events }
		end
	end

	def list
		# Get only the events that I created
		@events = Event.where("`events`.`user_id` = ?", self.current_user.id) if params.has_key?("mine") && !self.current_user.nil?

		# Get all event unless we are requesting "Mine"
		@events = Event.where("'1' = '1'") unless params.has_key?("mine") && !self.current_user.nil?

		# Get events that span a specific date
		if params.has_key?("date")
			date = Time.strptime(params["date"], "%m/%d/%Y").utc.strftime("%Y-%m-%d")
			@events = @events.where("date(`events`.`start_time`) = ?", date)
		end

		# Make sure the event is today or later
		@events = @events.where("`events`.`end_time` >= CURDATE()") if params.has_key?("future")

		# Search name and description
		@events = @events.where("lower(`events`.`name`) LIKE ? OR lower(`events`.`description`) LIKE ?", "%" + params["search"].downcase + "%", "%" + params["search"].downcase + "%") if params.has_key?("search")

		# Filter by Event Topics
		if params.has_key?("topic")
			@events = @events.joins("RIGHT JOIN `events_eventtopics` ON `events`.`id` = `events_eventtopics`.`event_id` LEFT JOIN `eventtopics` ON `events_eventtopics`.`eventtopic_id` = `eventtopics`.`id`")
			@events = @events.where("`eventtopics`.`name` = ?", params["topic"])
		end

		# Paginate and return all results
		@events = @events.page(params[:page]).all

		respond_to do |format|
			format.html { render :action => "index" }
			format.json { render json: @events }
		end
	end

	# GET /events/1
	# GET /events/1.json
	def show
		@event = Event.find(params[:id])
		@comments = @event.getComments
		self.log_analytic(:event_view, "A user viewed an event.", @event)
	end

	# GET /events/new
	# GET /events/new.json
	def new
		@event = Event.new

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @event }
		end
	end

	# GET /events/1/edit
	def edit
		@event = Event.find(params[:id])
	end

	# POST /events
	# POST /events.json
	def create

		# Reformat and merge in
		params[:event].merge!(_format_data(params[:event]))

		# Create the event beginning with the data provided
		@event = Event.new(params[:event])

		# Link up the event format
		if params.has_key?("eventformat")
			@event.eventformats = []
			@event.eventformats << Eventformat.find(params['eventformat'])
		end

		# Link up the topics that will be covered at this event
		if params.has_key?("eventtopic")
			@event.eventtopics = []
			params['eventtopic'].each do |topic|
				@event.eventtopics << Eventtopic.find(topic)
			end
		end

		# Load in skills
		if params.has_key?("skills")
			@event.skills = []
			params['skills'].each do |skill|
				@event.skills << Skill.find(skill)
			end
		end

		# Apply the current user as the owner
		@event.user = self.current_user

		respond_to do |format|
			if @event.save
				self.log_analytic(:event_creation, "A user created a new event.", @event)
				Whiteboard.createActivity(:event_create, "{user.link} just created an event: {tag.event_link}.", @event)
				format.html { redirect_to @event, notice: 'Event was successfully created.' }
				format.json { render json: @event, status: :created, location: @event }
			else
				format.html { render action: "new" }
				format.json { render json: @event.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /events/1
	# PUT /events/1.json
	def update
		@event = Event.find(params[:id])

		# Link up the event format
		if params.has_key?("eventformat")
			@event.eventformats = []
			@event.eventformats << Eventformat.find(params['eventformat'])
		end

		# Link up the topics that will be covered at this event
		if params.has_key?("eventtopic")
			@event.eventtopics = []
			params['eventtopic'].each do |topic|
				@event.eventtopics << Eventtopic.find(topic)
			end
		end

		# Load in skills
		if params.has_key?("skills")
			@event.skills = []
			params['skills'].each do |skill|
				@event.skills << Skill.find(skill)
			end
		end

		# Reformat and merge in
		params[:event].merge!(_format_data(params[:event]))

		respond_to do |format|
			if @event.update_attributes(params[:event])
				self.log_analytic(:event_update, "A user updated an event.", @event)
				format.html { redirect_to @event, notice: 'Event was successfully updated.' }
				format.json { head :ok }
			else
				format.html { render action: "edit" }
				format.json { render json: @event.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /events/1
	# DELETE /events/1.json
	def destroy
		@event = Event.find(params[:id])
		@event.destroy

		respond_to do |format|
			self.log_analytic(:event_deletion, "A user deleted a event.", @event)
			format.html { redirect_to events_url }
			format.json { head :ok }
		end
	end

	# Admin Pane for Events
	def admin_events
		@events = Event.all

		# Get events stats
		@stats = []
		@stats.push({:name => 'Total Events', :value => @events.nil? ? 0 : @events.count})

		# Prepare pagination
		@events = @events.paginate :page => params[:page], :per_page => 100 unless @events.nil?
	end

	# Invite someone to attend event
	def invite

		# Load the event
		@event = Event.find(params[:id])

		# Load in the current users name
		unless self.current_user.nil?
			name = self.current_user.name
		else
			name = "[name]"
		end

		# What is the default message for the email
		@default_message = "I thought you might be interested in joining me at \"#{@event.name}\" check it out on Tioki.\n\n-#{name}"
	end

	def invite_email

		# Load the event
		@event = Event.find(params[:id])

		# Get the post data key
		@referral = params[:referral]

		# Interpret the post data from the form
		@teachername = @referral[:teachername]
		@emails = @referral[:emails]
		@message = @referral[:message]

		# Swap out any instances of [name] with the name of the sender
		@message = @message.gsub("[name]", @teachername);

		# Swap out all new lines with line breaks
		@message = @message.gsub("\n", '<br />');

		# Get the current user if applicable
		user = self.current_user unless self.current_user.nil?

		# Send out the email to the list of emails
		UserMailer.event_invite_email(@teachername, @emails, @message, @event, user).deliver

		# Log this action
		self.log_analytic(:event_invitation, "A user invited someone to an event.", @event)

		# Return user back to the home page 
		redirect_to event_path(@event), :notice => 'Email Sent Successfully'
	end

	# RSVP to an event
	def rsvp
		# Load the event
		@event = Event.find(params[:id])

		# Connect the user to the event
		unless params.has_key?("disconnect")

			# If the RSVP deadline is up do not allow connecting
			#if @event.rsvp_deadline.nil? || @event.rsvp_deadline < Time.now
			#	return redirect_to event_path(@event), :notice => 'The RSVP Deadline for this event has expired'
			#end

			# If you are already connected return
			if self.current_user.rsvp.index(@event) != nil
				return redirect_to event_path(@event), :notice => 'You are already marked as attending.'    
			end

			# Create the connection
			self.current_user.rsvp << @event

			# Uniqify the array (remove duplicates just incase)
			self.current_user.rsvp.uniq!

			# Log the action
			self.log_analytic(:event_rsvp, "A user put in an rsvp to an event.", @event)

			# Show on whiteboard
			Whiteboard.createActivity(:event_rsvp, "{user.link} is now planning on going to {tag.event_link}.", @event)

			# Redirect back
			return redirect_to event_path(@event), :notice => 'You have submitted your RSVP for ' + @event.name
		end

		# Otherwise disconnect the event from the user
		self.current_user.rsvp.delete @event
		self.log_analytic(:event_unrsvp, "A user removed their rsvp to an event.", @event)
		return redirect_to event_path(@event), :notice => 'You have cancelled your RSVP for ' + @event.name
	end

	# Format the event data for create/update
	def _format_data(data)

		# Set the time for start_time properly
		if data.has_key?("start_time") && !data['start_time'].empty?
			data['start_time'] = Time.strptime(data['start_time'], "%m/%d/%Y %I:%M %p")
		end

		# Set the time for end_time properly
		if data.has_key?("end_time") && !data['end_time'].empty?
			data['end_time'] = Time.strptime(data['end_time'], "%m/%d/%Y %I:%M %p")
		end

		# Set the time for rsvp_deadline properly
		if data.has_key?("rsvp_deadline") && !data['rsvp_deadline'].empty? && data['rsvp_req'].to_i == 1
			data['rsvp_deadline'] = Time.strptime(data['rsvp_deadline'], "%m/%d/%Y %I:%M %p")
		elsif data['rsvp_req'].to_i == 0
			data['rsvp_deadline'] = nil
		end

		# Format the address elements into a single string
		address = ''
		address << data['loc_address'] if data.has_key?("loc_address")
		address << ' ' + data['loc_address1'] if data.has_key?("loc_address1")
		address << ', ' + data['loc_city'] if data.has_key?("loc_city")
		address << ', ' + data['loc_state'] if data.has_key?("loc_state")

		# Unless the string is empty build the latitude and longitude
		unless address.empty?
			begin
				latlon = Geocoder.search(address)[0].geometry['location']
				data['loc_latitude'] = latlon['lat']
				data['loc_longitude'] = latlon['lng']
			rescue NoMethodError
				# Ignore the exception
			end
		end

		# If there is a block then yield
		data = yield(data) if block_given?

		# Return the data
		return data
	end

	# Add a comment to an event
	def comment

		# Require an authenticated user
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Get the event in question
		event = Event.find(params[:id])

		# Create the comment
		comment = event.createComment(params[:comment])

		# save and get the proper message
		if comment.save
			message = {:type => :success, :message => "Successfully added comment.", :id => comment.id}
		else
			message = {:type => :error, :message => "There was an error posting your comment."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end
end
