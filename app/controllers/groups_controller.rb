class GroupsController < ApplicationController
	before_filter :login_required, :except => [:index, :show]
	before_filter :teacher_required, :except => [:index, :show]

	def index
		#@groups = Group.permissions(:slugs => {:public => 1, :private => 1}, :type => 'OR')
		@groups = Group.all
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
		#public
		group.permissions = 1

		respond_to do |format|
			if group.save
				#create join row
				#all three permissions 2^3-1
				User_Group.create(:user_id => self.current_user.id, :group_id => group.id, :permissions => 7)
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

	def add_group
		user_group = User_Group.find(:first, :conditions => ['user_id = ? && group_id = ?', self.current_user.id, params[:id]])
		if user_group
			redirect_to :back, :notice => "You have already added this group."
		else
			#add as member
			group = User_Group.create(:user_id => self.current_user.id, :group_id => params[:id], :permissions => 1)
			#self.log_analytic(:user_added_group, "A user added a group", group)
			redirect_to :back, :notice => "Technology was successfully added."
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
	
		def invite
  		return redirect_to :back unless request.post?
  		return redirect_to :back if User.current.nil?

  		# Get the discussion
  		d = Group.find(params[:id])

  		subject = "You have been invited to join the Group \"#{d.name}\"."
  		body = <<-BODY
  Hi, I was browsing Tioki's groups and I thought you might be interested in this group.
  Come join this group! <a href="http://tioki.com/groups/#{d.id}">Click Here</a>
  BODY

  		# Send the message
  		params[:connection].each do |user|
  			Message.send!(user, :subject => subject, :body => body.html_safe)
  		end

  		flash[:success] = "Share successfully."
  		return redirect_to :back
  	end
end
