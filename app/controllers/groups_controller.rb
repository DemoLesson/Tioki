class GroupsController < ApplicationController
	before_filter :login_required, :except => [:index, :show, :members, :about]
	before_filter :teacher_required, :except => [:index, :show, :members, :about]

	def index
		@groups = Group.permissions('OR', :public => true, :private => true)
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
				
				# Add the first administrator
				user_group.permissions = {:member => true, :moderator => true, :administrator => true}

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

		# Is the current user an administrator
		if self.current_user && @group.users.include?(User.current)
			@admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		else
			@admin = false
		end

		@comments = @group.get_comments

		# Is the current user in a group
		unless self.current_user.nil?
			@in_group = self.current_user.groups.include?(@group)
		else
			@in_group = false
		end
	end
	
  def members
    # Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		if self.current_user && @group.users.include?(User.current)
			@admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		else
			@admin = false
		end

		@comments = @group.get_comments

		# Is the current user in a group
		unless self.current_user.nil?
			@in_group = self.current_user.groups.include?(@group)
		else
			@in_group = false
		end
		
		# Get a list of my connections
    @my_connections = Connection.mine(:pending => false) unless self.current_user.nil?
    @my_connections = Array.new if self.current_user.nil?
  end
  
  def about
    # Load group
		@group = Group.find(params[:id])

		# Is the current user an administrator
		if self.current_user && @group.users.include?(User.current)
			@admin = @group.user_permissions.to_hash['administrator'] || User.current.is_admin
		else
			@admin = false
		end

		# Is the current user in a group
		unless self.current_user.nil?
			@in_group = self.current_user.groups.include?(@group)
		else
			@in_group = false
		end
  end
   
	def add_group
		user_group = User_Group.find(:first, :conditions => ['user_id = ? && group_id = ?', self.current_user.id, params[:id]])
		if user_group
			redirect_to :back, :notice => "You have already added this group."
		else
			#add as member
			user_group = User_Group.create(:user_id => self.current_user.id, :group_id => params[:id])

			#set as member
			user_group.permissions = {:member => true}

			#self.log_analytic(:user_added_group, "A user added a group", group)
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

		@group.update_attributes(params[:group])

		redirect_to @group
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
		else
			message = {:type => :error, :message => "There was an error posting your comment."}
		end

		# Respond with either html or json
		respond_to do |format|
			format.html { flash[message[:type]] = message[:message]; redirect_to :back }
			format.json { render :json => message }
		end
	end

	def my_groups
		@groups = self.current_user.groups
	end

	def edit_picture
		@group = Group.find(params[:id])
	end

	def inviting 

		# Load the group
		@group = Group.find(params[:id])

		# Load in the current users name
		unless self.current_user.nil?
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
		user = self.current_user unless self.current_user.nil?

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
		params[:connection].each do |user|
			Message.send!(user, :subject => subject, :body => body.html_safe)
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
end
