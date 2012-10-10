require 'mail'

class ConnectionsController < ApplicationController
	layout nil
	layout "application", :except => [:show_my_connections, :new_connections]
	before_filter :login_required, :except => [ :linkinvite]

	# GET /connections
	# GET /connections.json
	def index
		@my_connections = Connection.mine(:pending => false).collect{ |connection| connection.not_me.id }
		@teachers = Array.new
		teachers = Teacher.search(params[:connectsearch], params[:topic]).paginate(:per_page => 25, :page => params[:page]).each do |teacher|
			@teacher = teacher
			@teachers << render_to_string("connections/new_connections", :layout => false)
		end

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @connections }
		end
	end

	def add_connection(respond = true)
		# Check and see if we are already connected (or are pending)
		a = self.current_user.id
		b = params[:user_id]
		@previous = Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).first

		# If we are not go ahead and initiate the connection
		if @previous == nil

			# Create the connection
			@connection = Connection.new
			@connection.owned_by = a
			@connection.user_id = b

			# If everything saved ok
			if @connection.save

				# Notify the other user of my connection request
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
						end
					end
				end
			end

		# Were actually still pending
		elsif @previous.pending == true && @previous.user_id = a

			# Dry way of accepting the connection
			self.send('accept_connection', respond)

		# Whoops we're already connected
		else

			# If respond is set to true then lets redirect
			if respond

				# Redirect to "My Connections"
				respond_to do |format|
					format.html { redirect_to :back, :notice => "Connection request successfully sent." }
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
		b = params[:user_id]

		# Get the connection in question (A <-> B)
		@connect = Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).first

		# Make the connection no longer pending
		@connect.pending = false

		# If the connection saves
		if @connect.save

			Whiteboard.createActivity(:user_connection, "{user.teacher.profile_link} just connected with {tag.teacher.profile_link} you should too!", User.find(a == @connect.user_id ? @connect.owned_by : @connect.user_id))
			self.log_analytic(:user_connection_accepted, "Two users connection", @connect)

			# Redirect to My Connections page
			respond_to do |format|
				format.html { redirect_to :my_connections }
			end
		end
	end

	def my_connections
		# Get all not pending connections
		@connections = Array.new
		Connection.mine(:pending => false).paginate(:per_page => 5, :page => params[:page]).each do |connection|
			@connection = connection
			@connections << render_to_string("connections/show_my_connections", :layout => false)
		end
		@my_pending_connections = Connection.mine(:pending => true, :creator => false)
	end

	def userconnections
		@user = User.find(params[:id])
		@connections = Connection.user(params[:id])
		@my_connections = Connection.mine
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
		@default_message = "Hey! I'd absolutely love to add you to my educator network on Tioki."
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
				@user = User.find(:first, :conditions => ["email = ?", email])

				# If the user exists run a add connection
				if @user != nil

					# Make sure the user has a teacher profile
					if @user.teacher
						# This connection is now like a normal connection request
						if Connection.add_connect(self.current_user.id, @user.id)
							notice << "Your connection request to " + demail + " has been sent."
						else
							notice << demail + " has already been connected to."
						end

						# Notify the current session user

					# If the user is not a teacher then do notify that a connection cannot be made
					else
						notice << email + " cannot be connected with."
					end

				# If the email is not tied to a member then invite them
				else
					url = "http://#{request.host_with_port}/dc/#{User.current.invite_code}"

					# Send out the email
					mail = UserMailer.connection_invite(self.current_user, email, url, params[:message]).deliver

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

		# Take us home
		redirect_to :root, :notice => notice.join(' ')
	end

	def linkinvite
		user = User.find(:first, :conditions => ['users.invite_code = ?', params[:url]])
		if user
			redirect_to "/welcome_wizard?x=step1&invitecode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def welcome_wizard_invite
		user = User.find(:first, :conditions => ['users.invite_code = ?', params[:url]])
		if user
			redirect_to "/welcome_wizard?x=step1&welcomecode=#{user.invite_code}"
		else 
			redirect_to "/welcome_wizard?x=step1", :notice => "Invalid invite code."
		end
	end

	def show_my_connections
		connections = Connection.mine(:pending => false).paginate(:per_page => 5, :page => params[:page]).all
		return render :json => connections unless params[:raw].nil?

		divs = Array.new
		connections.each do |connection|
			@connection = connection
			divs << render_to_string
		end

		render :json => divs
	end

	def new_connections
		@my_connections = Connection.mine(:pending => false).collect{ |connection| connection.not_me.id }
		teachers = Teacher.search(params[:connectsearch], params[:topic]).paginate(:per_page => 25, :page => params[:page])
		return render :json => connections unless params[:raw].nil?

		divs = Array.new
		teachers.each do |teacher|
			@teacher = teacher
			divs << render_to_string
		end

		render :json => divs
	end

	def distance
		result = User.find(117091).distance(params[:id])
		render :text => (result.nil? ? 'nil' : result)
	end

	# DELETE /connections/1
	# DELETE /connections/1.json
	def destroy
		@connection = Connection.find(params[:id])
		@connection.destroy

		respond_to do |format|
			format.html { redirect_to connections_url }
			format.json { head :ok }
		end
	end
end
