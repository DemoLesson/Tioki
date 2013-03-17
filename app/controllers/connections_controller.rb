require 'mail'

class ConnectionsController < ApplicationController
	layout nil
	layout "application", :except => [:show_my_connections, :new_connections]
	before_filter :login_required, :except => [ :linkinvite]

	# GET /connections
	# GET /connections.json
	def index
		@my_connections = Connection.mine(:pending => false).collect{ |connection| connection.not_me.id }

		if params[:skill]
			users = User.search(:skill => params[:skill])
		elsif params[:connectsearch].empty?
			users = User.none
		elsif params[:topic].empty? || params[:topic] == 'name'
			users = User.search(:name => params[:connectsearch])
		elsif params[:topic] == 'email'
			users = User.search(:email => params[:connectsearch])
		elsif params[:topic] == 'school'
			users = User.search(:school => params[:connectsearch])
		elsif params[:topic] == 'skill_string'
			#Make sure this skill actually exists
			@skills = Skill.where("skills.name like ?", "#{params[:connectsearch]}%")
			if @skills.count > 0
				users = User.search(:skills => @skills.collect(&:id))
			else
				users = User.none
			end
		elsif params[:topic] == 'subject_string'
			#Make sure this subject actually exists
			@subjects = Subject.where("subjects.name like ?", "#{params[:connectsearch]}%")
			if @subjects.count > 0
				users = User.search(:subjects => @subjects.collect(&:id))
			else
				users = User.none
			end
		elsif params[:topic] == 'grade_string'
			#Make sure this grade actually exists
			@grades = Grade.where("grades.name like ?", "#{params[:connectsearch]}%")
			if @grades.count > 0
				users = User.search(:grades => @grades.collect(&:id))
			else
				users = User.none
			end
		elsif params[:topic] == 'location'
			users = User.search(:location => params[:connectsearch])
		else
			users = User.none
		end

		#Populate search options
		if params[:topic] == 'name'
			@companies = users.includes(:experiences).
				collect{|x|x.experiences.collect{|y|y.company}}.
				flatten.uniq.delete_if{|x|x.nil?||x.empty?}

			@user_skills = users.includes(:skills).collect(&:skills).flatten.uniq
			@subjects = users.includes(:subjects).collect(&:subjects).flatten.uniq
			@grades = users.includes(:grades).collect(&:grades).flatten.uniq

			#count returns a hash
			@locations = users.geocoded.group("country").count
			@locations.merge!(users.geocoded.group("state").count)
			@locations.merge!(users.geocoded.group("city").count)

			@locations.sort_by!{ |location, value| value }
			@locations.reverse!
		end
		
		# Paginate to 25 per
		@users = Array.new
		users.paginate(:per_page => 25, :page => params[:page], :order => "users.connections_count DESC").each do |user|
			@user = user
			@users << render_to_string("connections/new_connections", :layout => false)
		end

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: users }
		end
	end

	# Connections of a specific user
	def profile_connections
		findby = params[:slug] || params[:id]
		@user = User.find_by_slug(findby) if findby.is_a?(String)
		@user = User.find(findby) if findby.is_a?(Fixnum)

		@connections = Connection.user(@user.id).paginate(:per_page => 20, :page => params[:page])
		@my_connections = Connection.mine
	end

	def add_connection(respond = true)
		# Check and see if we are already connected (or are pending)
		a = self.current_user.id
		@user = User.find(params[:user_id])
		b = params[:user_id]
		@ab = params[:ab]
		@previous = Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).first
		@redirect = !currentUser.id.even? ? '/profile/' + @user.slug + '/about?add_connection=b' : false

		# If we are not go ahead and initiate the connection
		if @previous == nil

			# Create the connection
			@connection = Connection.new
			@connection.owned_by = a
			@connection.user_id = b

			# If everything saved ok
			if @connection.save

				# If we suggested the connection log it as an analytic
				if @ab == '0'
					self.log_analytic(:suggested_connection_created_subjects, 'A user created a connection based off our suggestion', @connection, [], :connections)
				elsif @ab == '1'
					self.log_analytic(:suggested_connection_created_grades, 'A user created a connection based off our suggestion', @connection, [], :connections)
				end

				# Notify the other user of my connection request
				self.log_analytic(:connection_request, "New connection request.", @connection, [], :connections)
				UserMailer.userconnect(a, b).deliver

				# If respond is set to true then lets redirect
				if respond

					# Redirect to "My Connections"
					respond_to do |format|
						if params[:to_wizard]
							session[:_ak] = "unlock_connection_request"
							format.html { redirect_to '/welcome_wizard?x=step2' }
						else
							format.html { redirect_to :back, :notice => "Connection request successfully sent."  }
							format.js
						end
					end
				end
			end

		# Were actually still pending
		elsif @previous.pending == true && @previous.user_id == a

			# Dry way of accepting the connection
			self.send('accept_connection', respond)

		# Whoops we're already connected
		else

			# If respond is set to true then lets redirect
			if respond

				# Redirect to "My Connections"
				respond_to do |format|
					format.html { redirect_to :back, :notice => "Connection request successfully sent." }
					format.js
				end
			end
		end
	end

	# Remove any pending connections
	# @TODO Deprecate this method
	def remove_pending(*args)

		# Redirect to remove connection since it is an unbiased connection removed and would do this anyway
		self.send('remove_connection', *args)
	end

	# Remove any connections between two users
	def remove_connection

		# Set A and B
		a = self.current_user.id
		b = params[:user_id]

		# Delete both A -> B and B -> A (If we missed any duplicated records)
		Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).each do |x|
			x.destroy
		end
		
		# Return to my connections
		respond_to do |format|
			format.html { redirect_to :my_connections }
		end
	end

	# Accept a connection invitation
	def accept_connection(respond = false)

		# Set A and B
		a = self.current_user.id
		@user = User.find(params[:user_id])
		b = params[:user_id]

		# Get the connection in question (A <-> B)
		@connect = Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).first

		# Make the connection no longer pending
		@connect.pending = false

		# If the connection saves
		if @connect.save

			Whiteboard.createActivity(:connection, "{user.link} just connected with {tag.link} you should too!", User.find(a == @connect.user_id ? @connect.owned_by : @connect.user_id))
			self.log_analytic(:user_connection_accepted, "Two users connection", @connect)

			# Redirect to My Connections page
			respond_to do |format|
				format.html { redirect_to :my_connections }
				format.js { render :action => "add_connection" }
			end
		end
	end

	def my_connections
		# Get all not pending connections
		@connections = Array.new
		@users = self.current_user.connections.includes(:user, :owner).not_pending.map(&:not_me)
		@users.paginate(:per_page => 20, :page => params[:page]).each do |user|
			@user = user
			@connections << render_to_string("connections/show_my_connections", :layout => false)
		end
		@my_pending_connections = Connection.mine(:pending => true, :creator => false)
	end

	#FOR old user connect emails
	def pending_connections
		redirect_to '/my_connections'
	end

	def add_and_redir

		# Make sure we have a user_id
		unless params.has_key?("user_id")
			raise StandardError, "Were missing the user id to connect to"
		end

		# Make sure we have a redirection url
		unless params.has_key?("redir")
			raise StandardError, "We can't redirect you anywhere unless you provide us with the url"
		end

		# Create the connection and redirect
		self.add_connection(false)
		redirect_to params['redir']
	end

	def inviteconnections
		@referred = self.current_user.successful_referrals.count
		@my_connection = Connection.find_for_user(self.current_user.id)

		@ab = Abtests.use("email:connection_invite", 1).to_s
		if @ab == "1"
			@default_message = "Hey! I'd absolutely love to add you to my education network on Tioki."
		else
			@default_message = "Hey!\n\nI would like you to join my education network on Tioki. Tioki is a place where educators gather, connect, and share new ideas! \n\nI think you would be a great fit for Tioki, so come join me!"
		end
	end

	def inviteconnection
		if params[:emails].nil? || params[:emails].size == 0
			return redirect_to :back, :notice => "Must have at least one email."
		end

		notice = []
		params[:emails].split(',').each do |email|
			# Clean up the email
			email = email.strip

			begin
				# Parse the email address
				mail = Mail::Address.new(email)
				demail = mail.address

				# Find the user by the provided email
				@user = User.where("email = ?", email).first

				# If the user exists run a add connection
				if @user != nil

					# This connection is now like a normal connection request
					if Connection.add_connect(self.current_user.id, @user.id)
						notice << "Your connection request to " + demail + " has been sent."
					else
						notice << demail + " has already been connected to."
					end

					# Notify the current session user

				# If the email is not tied to a member then invite them
				else
					url = "http://#{request.host_with_port}/dc/#{User.current.invite_code}"

					# Send out the email
					mail = UserMailer.connection_invite(self.current_user, email, url, params[:message], params[:ab]).deliver

					# Notify the current session member that ht e email was sent
					notice << "Your invite to " + demail + " has been sent."

					# Log an analytic
					self.log_analytic(:connection_invite_sent, "User invited people to the site to connect.", @user)
				end

				unless session[:wizard].nil?
					# Wizard Key
					wKey = "welcome_wizard_step5" + (session[:_ak].nil? ? '' : '_[' + session[:_ak] + ']')

					# And create an analytic
					self.log_analytic(wKey, "User completed step 5 of the welcome wizard.", self.current_user)

					# Delete this identifier
					session.delete(:wizard)
				end

			# If the email could not be parsed let the current session member know
			rescue Mail::Field::ParseError
				notice << "Could not parse " + email
			rescue
				notice << "Unknown Error"
			end
		end

		redirect_to "/inviteconnections", :notice => notice.join(' ')
	end

	def invite_twitter
		if self.current_user.twitter_auth?
			auth = self.current_user.twitter_auth
			client = Twitter::Client.new(
				:oauth_token => auth.token,
				:oauth_token_secret => auth.secret
			)

			if request.post? && !params[:people].nil?
				params.people.split(',').each do |twitter_contact|
					notice = "Success"
					begin
						client.direct_message_create(twitter_contact.to_i, "I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code} via @tioki")
					rescue Twitter::Error::Forbidden => ex

						if ex.message == "There was an error sending your message: Whoops! You already said that."
						else
							notice = "An error occured while attempting to message followers"
							break
						end
					rescue Twitter::Error::BadGateway
						notice = "Twitter is down or being upgraded."
					end
					flash[:notice] = notice
				end
			end

			@contacts = []

			followers = client.follower_ids

			#user lookup
			users = client.users(followers.ids)

			#just get id, name, profile_image, and screen name
			users.each do |twitter_contact|
				contact = Hash.new

				contact.name = twitter_contact.name
				contact.id = twitter_contact.id
				contact.picture = twitter_contact.profile_image_url
				contact.screen_name = twitter_contact.screen_name

				@contacts << contact
			end
		end
	end

	def invite_gmail
		if request.post? && !params[:people].nil?

			# Split people to invite and loop
			params.people.split(',').each do |email|

				# Parse the email to make sure its valid
				email = Mail::Address.new(email.strip)

				# Get the user
				user = User.where({"email" => email.address}).first

				# If the user exists
				unless user.nil?
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
					UserMailer.connection_invite(self.current_user, email, url, params[:message]).deliver

					# Log an analytic
					self.log_analytic(:connection_invite_sent, "User invited people to the site to connect.", self.current_user)
				end
			end
			flash[:notice] = "Success"
		end
	end

	def invite_yahoo
		if request.post? && !params[:people].nil?

			# Split people to invite and loop
			params.people.split(',').each do |email|

				# Parse the email to make sure its valid
				email = Mail::Address.new(email.strip)

				# Get the user
				user = User.where({"email" => email.address}).first

				# If the user exists
				unless user.nil?
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
					UserMailer.connection_invite(self.current_user, email, url, params[:message]).deliver

					# Log an analytic
					self.log_analytic(:connection_invite_sent, "User invited people to the site to connect.", self.current_user)
				end
			end
			flash[:notice] = "Success"
		end
	end

	def linkinvite
		user = User.where('users.invite_code = ?', params[:url]).first
		if user
			redirect_to "/welcome_wizard?x=step1&invitecode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def welcome_wizard_invite
		user = User.where('users.invite_code = ?', params[:url]).first
		if user
			redirect_to "/welcome_wizard?x=step1&welcomecode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def invite_from_twitter
		user = User.where('users.invite_code = ?', params[:url]).first
		if user
			redirect_to "/welcome_wizard?x=step1&twittercode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def invite_from_facebook
		user = User.where('users.invite_code = ?', params[:url]).first
		if user
			redirect_to "/welcome_wizard?x=step1&facebookcode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def show_my_connections
		users = self.current_user.connections.includes(:user, :owner).not_pending.map(&:not_me).paginate(:per_page => 20, :page => params[:page])

		divs = Array.new
		users.each do |user|
			@user = user
			divs << render_to_string
		end

		render :json => divs
	end

	def new_connections
		@my_connections = Connection.mine(:pending => false).collect{ |connection| connection.not_me.id }

		# Build Hash
		search = Hash.new
		search[:skill] = params[:skill] if params[:skill]
		search[:skills] = params[:skills] if params[:skills]
		search[:school] = params[:school] if params[:school]
		search[:schools] = params[:schools] if params[:schools]
		search[:locations] = params[:locations] if params[:locations]
		search[:subjects] = params[:subjects] if params[:subjects]
		search[:grades] = params[:grades] if params[:grades]
		search[:email] = params[:connectsearch] if params[:connectsearch] && params[:topic] == 'email'
		search[:school] = params[:connectsearch] if params[:connectsearch] && params[:topic] == 'school'
		search[:name] = params[:connectsearch] if params[:connectsearch] && 
			(params[:topic].nil? || params[:topic] == 'name')
		search[:location] = params[:connectsearch] if params[:connectsearch] && params[:topic] == 'location'
		search[:skills] = Skill.where("skills.name like ?", "#{params[:connectsearch]}%").collect(&:id) if params[:connectsearch] &&
			params[:topic] == 'skill_string'
		search[:skills] = Subject.where("subjects.name like ?", "#{params[:connectsearch]}%").collect(&:id) if params[:connectsearch] &&
			params[:topic] == 'subject_string'
		search[:grades] = Grade.where("grades.name like ?", "#{params[:connectsearch]}%").collect(&:id) if params[:connectsearch] &&
			params[:topic] == 'grade_string'

		unless search.empty?
			users = User.search(search)
		else
			users = Array.new
		end

		# Review
		# Paginate rescue cause it will fail on empty arrays ^^
		users = users.paginate(:per_page => 25, :page => params[:page], :order => "connections_count DESC") rescue Array.new

		# Return raw json
		return render :json => users unless params[:raw].nil?
		
		divs = Array.new
		users.each do |user|
			@user = user
			divs << render_to_string
		end

		render :json => divs
	end

	def social_friends
		facebook_users = []
		twitter_users = []

		if self.current_user.facebook_auth?
			facebook_users = self.current_user.facebook_friends
		end

		if self.current_user.twitter_auth?
			twitter_users = self.current_user.twitter_friends
		end

		@users = facebook_users | twitter_users

		if @users.empty?
			return redirect_to :root
		end
	end

	def connect_social_friends
		facebook_users = []
		twitter_users = []

		if self.current_user.facebook_auth?
			facebook_users = self.current_user.facebook_friends
		end

		if self.current_user.twitter_auth?
			twitter_users = self.current_user.twitter_friends
		end

		@users = facebook_users | twitter_users

		@users.each do |user|
			Connection.delay.add_connect(self.current_user.id, user.id)
		end

		redirect_to :root
	end

	# Review
	def distance
		result = User.find(117091).distance(params[:id])
		render :text => (result.nil? ? 'nil' : result)
	end

	def destroy
		@connection = Connection.find(params[:id])
		@connection.destroy

		respond_to do |format|
			format.html { redirect_to connections_url }
			format.json { head :ok }
		end
	end
end
