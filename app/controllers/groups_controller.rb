class GroupsController < ApplicationController
	before_filter :login_required, :except => [:index, :show, :members, :about]
	before_filter :source_owner, :only => :index

	def index
		if params[:organization] == 'true'
			@groups = @source.organization
			@type = 'Organization'
			@featured_jobs = Job.where("featured = ?", true).limit(3)
		else
			@groups = @source.organization!
			@type = 'Group'
			@featured_groups = Group.where("featured = ?", true).limit(4)
		end

		if params[:group_search]
			@groups = @groups.where("name like ?", "%#{params[:group_search]}%")
		end
	end

	def new
		@group = Group.new

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @group }
		end
	end

	def create
		group = Group.new(params[:group])

		respond_to do |format|
			if group.save

				# Set permissions
				group.permissions = {:public => true}

				# Create join row for users -> groups
				user_group = User_Group.new
				user_group.user_id = self.current_user.id
				user_group.group_id = group.id
				user_group.save

				#Log into Analytics 
				self.log_analytic(:group_creation, "New group was created.", group, [], :groups)

				# Add the first administrator
				user_group.permissions = {:member => true, :moderator => true, :administrator => true, :owner => true}

				# Return HTML or JSON
				format.html { redirect_to group, notice: 'Group was successfully created.' }
				format.json { render json: group, status: :created, location: group }
			else
				format.html { render action: "new" }
				format.json { render json: group.errors, status: :unprocessable_entity }
			end
		end
	end

	def show
		# Load group
		@group = Group.find(params[:id])

		# Redirect to discussions if no long description
		if @group.long_description.nil?
			# If redirected to keep the flash from
			# the last request
			flash.keep
			redirect_to group_path(@group) + '/discussions'
		end
	end

	def members
		# Load group
		@group = Group.find(params[:id])

		# Get a list of my connections
		@my_connections = Connection.mine(:pending => false).collect { |connection| connection.not_me_id(currentUser.id) } unless currentUser.new_record?
		@my_connections = Array.new if currentUser.new_record?
	end

	def discussions
		# Load group
		@group = Group.find(params[:id])

		# Group Discussions
		@discussions = @group.discussions.order("created_at DESC").paginate(:per_page => 15, :page => params[:page])
	end

	def jobs
		# Load organization
		@group = Group.find(params[:id])

		# Organization jobs
		@jobs = @group.jobs.where(:status => 'running').order("created_at DESC").limit(@group.job_allowance)
	end

	def add_group
		user_group = User_Group.where('user_id = ? && group_id = ?', self.current_user.id, params[:id]).first
		if user_group
			redirect_to :back, :notice => "You have already added this group."
		else
			#add as member
			user_group = User_Group.create(:user_id => self.current_user.id, :group_id => params[:id])

			#set as member
			user_group.permissions = {:member => true, :discussion_notifications => true}

			self.log_analytic(:user_joined_group, "A user joined a group", user_group.group, [], :groups)
			redirect_to user_group.group, :notice => "Group was successfully added."
		end
	end

	def edit

		# If the user is not logged in the user is unauthorized
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		raise HTTPStatus::Unauthorized unless admin

	end

	def update

		# If the user is not logged in the user is unauthorized
		raise HTTPStatus::Unauthorized if User.current.nil?

		# Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		raise HTTPStatus::Unauthorized unless admin

		# Update permissions
		permissions = Hash.new
		permissions[:public] = params.group.permissions.try(:public) == 'true'
		permissions[:private] = params.group.permissions.try(:public) != 'true'
		permissions[:hidden] = params.group.permissions.try(:hidden) == 'true'

		if currentUser.is_admin
			permissions[:organization] = params.group.permissions.try(:organization) == 'true'
		end

		permissions[:public_discussions] = params.group.permissions.try(:public_discussions) == 'true'
		params[:group].delete_if { |k, v| k.to_s == 'permissions' }
		@group.permissions = permissions

		@group.misc = params[:group][:misc] if params[:group][:misc]
		@group.social = params[:group][:social] if params[:group][:social]
		@group.location = params[:group][:location] if params[:group][:location]

		@group.update_attributes(params[:group])
		if @group.save
			flash[:success] = "Successfully updated"
			redirect_to @group
		else
			flash[:error] = "Did not update"
			redirect_to @group
		end

	end

	# Add a comment to an group
	def comment
		# Get the group in question
		group = Group.find(params[:id])

		# Require an authenticated user that has joined the group
		group = Group.find(params[:id])
		raise HTTPStatus::Unauthorized if User.current.nil? || !group.users.include?(User.current)

		# Create the comment
		comment = group.create_comment(params[:comment])

		# save and get the proper message
		if comment.save
			message = {:type => :success, :message => "Successfully added comment.", :id => comment.id}
			self.log_analytic(:user_comment_in_group, "User has commented in group.", comment, [], :groups)
		else
			message = {:type => :error, :message => "There was an error posting your comment."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

	def edit_picture
		@group = Group.find(params[:id])
	end

	def inviting

		# Load the group
		@group = Group.find(params[:id])

		# Load in the current users name
		unless currentUser.new_record?
			name = self.current_user.name
		else
			name = "[name]"
		end

		# What is the default message for the email
		@default_message = "I thought you might be interested in joining the \"#{@group.name}\" group. Check it out on Tioki.\n\n-#{name}"
	end

	def invite_email

		# Load the event
		@group = Group.find(params[:id])

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
		user = self.current_user unless currentUser.new_record?

		# Send out the email to the list of emails
		UserMailer.group_invite_email(@teachername, @emails, @message, @group, user).deliver

		# Return user back to the home page 
		redirect_to group_path(@group), :notice => 'Email Sent Successfully'
	end

	def invite
		return redirect_to :back unless request.post?
		return redirect_to :back if User.current.nil?

		# Get the discussion
		d = Group.find(params[:id])

		subject = "You have been invited to join the Group \"#{d.name}\"."
		body = <<-BODY
	Hi, I was browsing Tioki's groups and I thought you might be interested in this group.
	Come join! <a href="http://tioki.com/groups/#{d.id}">Click Here</a>
		BODY

		# Send the message
		if params[:connection]
			params[:connection].each do |user|
				Message.send!(user, :subject => subject, :body => body.html_safe)
			end
		end

		flash[:success] = "Share successfully."
		return redirect_to :back
	end

	def message_all_new
		@group = Group.find(params[:id])
		@message = Message.new
	end

	def message_all_create
		@group = Group.find(params[:id])
		if @group.user_permissions.to_hash['administrator'] || User.current.is_admin
			@group = Group.find(params[:id])
			message = "To all members of <a href='http://#{request.host_with_port}/groups/#{@group.id}'>#{@group.name}</a>: " + params[:message][:body]

			@group.users.each do |user|
				Message.send!(user, :subject => params[:message][:body], :body => message)
			end
			redirect_to @group, :notice => "Messages successfully sent."
		else
			redirect_to :back, "Unauthorized"
		end
	end

	def add_admin
		group = Group.find(params[:id])

		# Check for permissions
		raise HTTPStatus::Unauthorized unless group.user_permissions['administrator'] || User.current.is_admin

		group.user_permissions(:update => {'administrator' => true}, :user => params[:user])
		redirect_to :back
	end

	def rmv_admin
		group = Group.find(params[:id])

		# Check for permissions
		raise HTTPStatus::Unauthorized unless group.user_permissions['administrator'] || User.current.is_admin

		group.user_permissions(:update => {'administrator' => false}, :user => params[:user])
		redirect_to :back
	end

	protected

	def source_owner
		if !params[:user_id].nil?
			@source = User.find(params[:user_id]).groups
		else
			@source = Group.permissions('OR', :public => true, :private => true).permissions(:hidden => false)
		end
	end
end
