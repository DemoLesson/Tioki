class UsersController < ApplicationController
	before_filter :login_required, :only=>[:welcome, :change_password, :choose_stored, :edit, :profile_stats, :get_started, :privacy]
	before_filter :authenticate, :only => [:fetch_code, :user_list, :school_user_list, :teacher_user_list, :deactivated_user_list, :organization_user_list,:manage, :referral_user_list, :donors_choose_list, :active_job_list, :geography]

	def create(*args)
		if request.post?
			# Create a new user with the paramaters provided
			@user = User.new(params[:user])
			@success = ""

			# Attempt to save the user
			if @user.save

				# Authenticate the user
				session[:user] = User.authenticate(@user.email, @user.password)

				# Log the signup
				self.log_analytic(:user_signup, "New user signed up.", @user)

				# Notice the signup was successful
				flash[:success] = "Signup successful"

				# Set to splash for analytics
				session[:_ak] = "splash"

				# Redirect to the wizard
				return redirect_to '/welcome_wizard?x=step2'

				# If there were any errors flash them and send :root
			else
				flash[:error] = error = @user.errors.full_messages.to_sentence
				Rails.logger.debug "User failed to register: " + error
				return redirect_to :root
			end
		end

		redirect_to :root
	end

	def swap_dashboard
		if currentUser.organization? && params[:switch] == 'recruiter'
			currentUser.update_attribute(:dashboard, params[:switch])
		end

		if params[:switch] == 'educator'
			currentUser.update_attribute(:dashboard, params[:switch])
		end

		redirect_to :root
	end

	def login
		return redirect_to :root unless currentUser.new_record?

		if request.post?
			if session[:user] = User.authenticate(params[:user][:email], params[:user][:password])

				# Log an analytic about the uer loggin in
				self.log_analytic(:user_logged_in, "User logged in.")
				Rails.logger.info "Login successful: #{params[:user][:email]} logged in."

				# Up the user login count
				currentUser.update_login_count

				# Remember the user
				if params[:remember_me]
					login_token = LoginToken.generate_token_for!(session[:user])
					cookies[:login_token_user] = { :value => login_token.user_id, :expires => login_token.expires_at }
					cookies[:login_token_value] = { :value => login_token.token_value, :expires => login_token.expires_at }
					Session.where(:session_id => request.session_options[:id]).first.update_attribute(:remember, true)
				end

				# Is there a location we should return the user to
				return_to = session[:return_to] || :root
				session.delete(:return_to) if session[:return_to]

				return redirect_to return_to
			else
				Rails.logger.debug "Login unsuccessful: username or password was incorrect."
				flash[:error] = "Your username or password was incorrect."
			end
		end
	end

	def logout
		reset_session
		flash[:notice] = "You've been logged out."

		# Delete login token
		if (login_token = LoginToken.find_by_user_id(cookies[:login_token_user]))
			cookies[:login_token_user] = { :value => nil, :expires => Time.new - 1.day }
			cookies[:login_token_value] = { :value => nil, :expires => Time.new - 1.day }
			login_token.destroy
		end

		redirect_to :root
	end

	def forgot_password
		@message = ""
		if request.post?
			@u = User.find_by_email(params[:user][:email])
			if @u and @u.send_new_password
				message = "A new password has been sent by email."
				flash[:notice] = message
				redirect_to :action => :login
			else
				@message = "Couldn't send password, check if the email you provided was correct."
			end
		end
	end

	def edit
		@user = currentUser
	end

	def profile_edit
		if User.current.nil?
			return render :json => {"message" => "Nothing"}
		end

		# Get the current teacher
		@user = User.current

		if request.post?
			@user.social = params[:social]
			@user.contact = params[:contact]
			params[:user].collect!{|k,v| v.split(',').collect{|x|x.to_i} if ['subject','grade'].include?(k)}
			@user.subjects = params[:user][:subject].collect{|x| Subject.find(x)}
			@user.grades = params[:user][:grade].collect{|x| Grade.find(x)}

			@user.slug = params[:slug].parameterize
			@user.headline = params[:headline]
			@user.location = params[:location]

			if @user.save
				flash[:success] = "Successfully updated"
				redirect_to :back
			else
				flash[:error] = @user.errors.full_messages.to_sentence
				redirect_to :back
			end
		end

		# Get the teachers skills
		@skills = @user.skills
		# Get the teachers last video
		@video = @user.videos.last
	end
	
	def profile_complete
		params[:user].collect!{|k,v| v.split(',').collect{|x|x.to_i} if ['subject','grade','skill'].include?(k)} if params[:user]
		currentUser.subjects = params[:user][:subject].collect{|x| Subject.find(x)} if params.user.try(:subject)
		currentUser.grades = params[:user][:grade].collect{|x| Grade.find(x)} if params.user.try(:grade)
		currentUser.skills = params[:user][:skill].collect{|x| Skill.find(x)} if params.user.try(:skill)

		if params[:education]
			currentUser.educations.build(params[:education])
		end

		if params[:experience]
			params[:experience][:startMonth]= params[:date][:startMonth]
			params[:experience][:startYear] = params[:date][:startYear]
			params[:experience][:endMonth] = params[:date][:endMonth]
			params[:experience][:endYear] = params[:date][:endYear]

			currentUser.experiences.build(params[:experience])
		end

		currentUser.update_attributes(params[:user]) if params[:user]
		currentUser.social = params[:social] if params[:social]
		currentUser.save

		respond_to do |format|
			format.js {render :nothing => true}
		end
	end

	def accounts
		@organization = self.current_user.organization
		if self.current_user.is_shared
			u=SharedUsers.where(:user_id => self.current_user.id).first
			@user = User.find(u.owned_by)
		else
			@user = self.current_user
		end

    # @todo is this still needed / deprecate?
		if self.current_user.is_shared
			sharedschool = SharedUsers.where(:user_id => self.current_user.id).first
			@members = SharedUsers.where(:owned_by => sharedschool.owned_by).all
		else
			@members = SharedUsers.where(:owned_by => self.current_user.id).all
		end
	end

	def update
		# Get the currently logged in user
		@user = currentUser

		# Group notification settings
		if params[:group] && params[:group][:discussions]

			# Is all or none set
			all = params[:group][:discussions][:all] if params[:group][:discussions][:all]
			none = params[:group][:discussions][:none] if params[:group][:discussions][:none]

			# Determine if we should set all to true or false
			value = all && none ? false : (none ? false : true) if all || none

			# Set the value in the user permissions
			for group in @user.groups

				# If override value is set use it if not then use the local one
				set = !value.nil? ? value : (params[:group][:discussions][group.id.to_s.to_sym] ? true : false)
				group.user_permissions(:update => {:discussion_notifications => set})
			end

			# Redirect back to the edit page
			return redirect_to :back, :notice => "Group notification settings have been updated."
		end

		# Email notification settings
		if params[:email]

			# Is all or none set
			all = params[:email][:all] if params[:email][:all]
			none = params[:email][:none] if params[:email][:none]

			# Determine if we should set all to true or false
			value = all && none ? false : (none ? false : true) if all || none

			# Delete the all or none keys
			save = params[:email].delete_if{|k,v|[:all, :none, :x, 'x'].include?(k)}

			# Get the proper daily digest setting
			save[:daily] = 0 if params[:email][:daily].nil?

			# If follow all set everything to 2 hours
			APP_CONFIG.notification_buckets.each{|key|save[key.to_sym] = 7200} if value == true

			# Make sure were saving integers not string
			save = save.collect{|k,v|value == false ? 0 : v.to_i}

			# Set the value in the user settings
			@user.update_attribute(:notification_intervals, save)

			# Redirect back to the edit page
			return redirect_to :back, :notice => "Email notification settings have been updated."
		end

		# Image upload
		if params[:user] && !(params[:user][:avatar].content_type.include? "image")
			return redirect_to :back, :notice => "The file was not an image."
		elsif params[:user]
			# Move temporary file created by uploader
			# To a file that won't disapper after the completion of the request
			directory = Rails.root.join('public/uploads')
			path = File.join(directory, params[:user][:avatar].original_filename.parameterize)
			File.open(path, "w+b") {|f| f.write(params[:user][:avatar].read) }
			@user.update_attribute(:temp_img_name, '/uploads/'+params[:user][:avatar].original_filename.parameterize)
			@user.update_attribute(:original_name,  params[:user][:avatar].original_filename.parameterize)
			respond_to do |format|
				format.js
			end
			return
		end

		redirect_to :back
	end

	def crop_image_temp
		@user = self.current_user

		# Load in the existing image file
		orig_img = MiniMagick::Image.new(Rails.root.join('public' + @user.temp_img_name))

		if(params[:user][:crop_x].present? && params[:user][:crop_y].present? && params[:user][:crop_w].present? && params[:user][:crop_h].present?)

			# Prepare the crop arguments
			args = "#{params[:user][:crop_w].to_i}x#{params[:user][:crop_h].to_i}+#{params[:user][:crop_x].to_i}+#{params[:user][:crop_y].to_i}"

			# Crop the image
			orig_img.crop(args)

		else
		
			# Crop using the smallest side
			if orig_img[:width] > orig_img[:height]
				smallest_side = orig_img[:height]
				offsetx = (orig_img[:width] - smallest_side)/2
				offsety = 0
			else
				smallest_side = orig_img[:width]
				offsetx = 0
				offsety = 0
			end

			args = "#{smallest_side}x#{smallest_side}+#{offsetx}+#{offsety}"

			orig_img.crop(args)
		end

		# Create temp file in order to save the cropped image for later saving to amazon s3
		tmp_img = File.new(orig_img.path)

		# Update the avatar with the tmp image
		@user.update_attribute(:avatar, tmp_img)

		# Log to the whiteboard that a user updated their profile picture
		Whiteboard.createActivity(:avatar_update, "{user.link} updated their profile picture.")

		# Redirect to the file url
		respond_to do |format|
			format.html {redirect_to(!currentUser.new_record? ? :back : :root, :notice => "Image changed successfully.") }
			format.js
		end
	end

	def crop
		@user=self.current_user
	end

	def crop_image
		@user = User.find(self.current_user.id)
		orig_img = Magick::ImageList.new(@user.avatar.url(:original))
		if(params[:user][:crop_x].present? && params[:user][:crop_y].present? && params[:user][:crop_w].present? && params[:user][:crop_h].present?)

			args= [params[:user][:crop_x].to_i,params[:user][:crop_y].to_i,params[:user][:crop_w].to_i,params[:user][:crop_h].to_i]

			orig_img.crop!(*args)
		else
			#crop values have not been set, just resize to fit 1:1 aspect ratio
			#the size of the image will be whatever side is smaller
			if orig_img.rows > orig_img.columns
				orig_img.resize_to_fill!(orig_img.columns, orig_img.columns)
			else
				orig_img.resize_to_fill!(orig_img.rows, orig_img.rows, Magick::NorthGravity)
			end
		end
		#Create temp file in order to save the cropped image for later saving to amazon s3
		tmp_img=Tempfile.new(@user.avatar_file_name, Rails.root.join('tmp'))

		#Set file to binary write, otherwise an attempt to convert from ascii 8-bit to UTF-8 will occur
		tmp_img.binmode
		orig_img.format="jpeg"
		tmp_img.write(orig_img.to_blob)
		@user.update_attribute(:avatar, tmp_img)
		tmp_img.close
		redirect_to :root, :notice => "Image changed successfully."
	end

	def change_picture
		@user = User.find(self.current_user.id)
	end

	def update_settings
		@user = User.find(self.current_user.id)
		action = @user.update_settings(params[:user])
		self.log_analytic(:user_updated_settings, "A user changed their settings.")

		respond_to do |format|
			format.html { redirect_to :root, :notice => action }
		end
	end

	def change_password
		@user = User.find(self.current_user.id)
		action = @user.change_password(params[:confirm])
		self.log_analytic(:user_changed_password, "A user changed their password.")

		respond_to do |format|
			format.html { redirect_to :root, :notice => action }
		end
	end

	def email_settings
		@user = User.find(self.current_user.id)

		# Update BitSwitch with the new permissions
		@user.email_permissions = params[:permissions], true

		# Update changed attributes
		@user.update_attributes params[:user]

		# Log this change
		self.log_analytic(:user_changed_email_settings, "A user changed their email settings.")

		respond_to do |format|
			format.html { redirect_to :root, :notice => "You have updated your email settings." }
		end
	end

	def change_org_info
		@organization = self.current_user.organization
		if self.current_user.is_shared
			u=SharedUsers.where(:user_id => self.current_user.id).first
			@user=User.find(u.owned_by)
		else
			@user = User.find(self.current_user.id)
		end
		@user.update_attributes(:email=>params[:email],:name=>params[:name])
		@organization.update_attribute(:name, params[:organization])
		self.log_analytic(:organization_info_changed, "A organization changed their information.")
		redirect_to :root
	end

	def user_list
		@users = User.order('created_at DESC').all
		@teachercounter = 0
		@schoolcounter = 0
		@schoolsnumber = 0
		respond_to do |format|
			format.html { render :user_list }
		end
	end

	def teacher_user_list

		# Search for a specific user via name or id
		if params[:tname]
			#is it a valid integer?
			if params[:tname].numeric?
				@users = User.where('id = ?', params[:tname]).order('users.created_at DESC')
			else
				@users = User.where('name LIKE ?', "%#{params[:tname]}%").order('users.created_at DESC')
			end
		else
			@users = User.order('users.created_at DESC')
		end

		# Limit to those that have at least 1 video
		@users = @users.joins(:videos).where('users.id = videos.user_id') if params[:vid]

		# Limit to teachers that have job applications
		@users = @users.joins(:applications).where('users.id = applications.user_id') if params[:applied]

		@educatorcount = User.organization?.count

		#count videos as 1 per user
		@videos = User.joins(:videos).where('users.id IN (?)', @users.collect(&:id)).count

		# Paginate the users
		@users = @users.paginate :page => params[:page], :per_page => 100

		# Prepare the stats for the admin page
		@stats = []
		@stats.push({:name => 'Registered Users', :value => User.count})
		@stats.push({:name => 'Videos Uploaded', :value => @videos})
		@stats.push({:name => 'Number of Organization Owners', :value => @educatorcount})

		# Render the page
		render :teacher_user_list
	end

	def deactivated_user_list
		if request.post?
			@user = User.unscoped.find(params[:user])
			@user.update_attribute(:deleted_at, nil)
		end
		@users = User.unscoped.find(:all)
		@users=@users.reject { |user| user.deleted_at == nil }

		@usercount = @users.count
		@teachercount = @users.reject { |user| user.nil? }.count
		@admincount = @users.reject { |user| user }.count

		@stats = []
		@stats.push({:name => 'Deactivated Users', :value => @users.count})
		@stats.push({:name => 'Deactivated Teachers', :value => @teachercount})
		@stats.push({:name => 'Deactivated Admins', :value => @admincount})

		@users=@users.paginate :page => params[:page], :per_page => 100
	end

	def donors_choose_list
    # @todo find a better way to do this
		@users = User.joins(:connection_invites).where('connection_invites.user_id = users.id && connection_invites.created_user_id IS NOT NULL && donors_choose = true AND connection_invites.created_at < ?', "2012-10-22 20:00:00").all.uniq.paginate(:per_page => 100, :page => params[:page])
	end

	def referral_user_list
		# after donors choose before tioki bucks
    # @todo find a better way to do this
		@users = User.joins(:connection_invites).where('connection_invites.user_id = users.id && connection_invites.created_user_id IS NOT NULL AND connection_invites.created_at > ? and connection_invites.created_at < ?', "2012-10-22 20:00:00", TIOKI_BUCKS_START).all.uniq.paginate(:per_page => 100, :page => params[:page])
	end

	def organization_user_list
		@organizations = Group.organization
		@organizations = @organizations.where("name LIKE '%#{params[:orgname]}%'") if params[:orgname]
		@organizations = @organizations.paginate :page => params[:page], :per_page => 25

		@stats = []
		@stats.push({:name => 'Organizations', :value => @organizations.count})
		@stats.push({:name => 'Administrators', :value => User_Group.permissions(:administrator).count })
	end

	def active_job_list
		@jobs = Job.is_active

	end

	def geography
		@users = User.where('country = ?', false).all

		@stats = []
		@stats.push({:name => 'Registered Users', :value => User.count})
	end

	def manage
		@organization = Group.find(params[:id])

		if request.post?
			return redirect_to :back, :notice => 'You are not authorized to do this action.' unless currentUser.is_admin

			# Add parameters
			params[:jobpack][:group] = @organization
			params[:jobpack][:expiration] = Chronic.parse(params[:jobpack][:expiration])
			params[:jobpack][:inception] = Chronic.parse(params[:jobpack][:inception])

			# Create a new job pack
			JobPack.create(params[:jobpack])

			redirect_to '/organizationlist'
		end
	end

	def tioki_coins_list
		#get users tioki dollars except from those that received
		#them solely from getting started which depends on 6 different tables
    # @todo make cleaner query instead of using .collect which recursively get the value
		connection_invites = ConnectionInvite.where("connection_invites.created_at > ?", TIOKI_BUCKS_START).all.collect(&:user_id)
		@teachers = Teacher.find(:all, :conditions => ["teachers.facebook_connect = true || teachers.twitter_connect = true || teachers.tweet_about = true || teachers.user_id IN (?)", connection_invites])
	end

	def edit_member
		@user = User.find(params[:id])
		@schools = self.current_user.schools 
		if request.post?
			if self.current_user.is_limited
				redirect_to :back, :notice => 'You are not authorized to do this action.'
				return
			end
			@user.update_attributes(:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email])
			@user.update_attribute(:is_limited, params[:is_limited])
			#on update delete all rows then reGreate based on editted version if the user is_limited
			if @user.is_limited == true
				SharedSchool.where(:user_id => @user.id).destroy_all
				params[:school_ids].each do |school|
					schoolowner = School.find(school)
					SharedSchool.create(:owned_by => schoolowner.owned_by, :school_id => school, :user_id => @user.id)
				end
			end
			flash[:notice] = "User update successful"
			redirect_to '/accounts/'+self.current_user.id.to_s
		end
	end

	# @todo! verify usage
	def new_member
		@schools = self.current_user.schools 
		if request.post?
			if params[:is_limited] == nil
				redirect_to :back, :notice => 'You must select a type'
				return
			end
			if params[:school_ids] == nil && params[:is_limited] == true
				redirect_to :back, :notice => 'You must select at least one school'
				return
			end
			if self.current_user.is_limited
				redirect_to :back, :notice => 'You are not authorized to do this action.'
				return
			end
			total=self.current_user.organization.totaladmins
			if self.current_user.organization.admin_allowance <= (total)
				flash[:notice]="Your current admin account allowance is too small to create this user.  Please contact support in order to increase it."
				return
			end
			@user= User.new(:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])

			if @user.save
				self.current_user.organization.update_attribute(:totaladmins,total+1)
				schoolowner=nil
				@user.update_attribute(:is_limited, params[:is_limited])
				@user.update_attribute(:is_shared, true)
				SharedUsers.create(:owned_by => self.current_user.organization.owned_by, :user_id => @user.id)
				if @user.is_limited == true
					params[:school_ids].each do |school|
						schoolowner = School.find(school)
						SharedSchool.create(:owned_by => schoolowner.owned_by, :school_id => school, :user_id => @user.id)
					end
				end
				flash[:notice] = "User creation successful"
				redirect_to '/accounts/'+self.current_user.id.to_s
			else
				redirect_to :back, :notice => @user.errors.full_messages.to_sentence
			end
		end
	end

	def destroy
		@user = User.find(params[:id])
		if params[:deactivate] 
			@user.update_attribute(:deleted_at, Time.now)
		else
			@user.cleanup
			@user.destroy
		end
		#stay on same page
		redirect_to :back
	end

	# Privacy method
	def privacy

		# Get the current logged in user
		@user = User.find(self.current_user.id)

		if request.post?
			# Get and update BitSwitch
			@user.privacy_public = Hash[params[:public].map{|key,val| [key.to_sym, val == "1"]}]

			# Reload page
			redirect_to :action => :privacy
		end
	end

	def banners
		if request.post?

			# Get unprocessed time
			time = params[:time]
			time = time.split(' ')

			# Determine if this is a recurring slot
			every = time.slice!(time.index("every")) == "every" rescue false

			begin
				# Assume a date range is specified if not an exception will be thrown
				from = time[0...time.index("to")].delete_if{|x| x == "from"}.join(' ')
				to = time[0...time.index("to") - 2].concat(time[time.index("to") + 1 .. -1]).join(' ')
			rescue

				# If no from was found then no date range was specified
				if time.index("from").nil?
					to = from = time.join(' ')

					# If a from was specified assume they meant the remainder of the day
				else
					from = time.delete_if{|x| x == "from"}.join(' ')
					time[-1] = 'midnight'
					to = time.join(' ')
				end
			end

			# If we only have one date to parse
			if to == from
				time = [Chronic.parse(to)]

				# If we have two
			else
				time = Array.new
				time << Chronic.parse(from)
				time << Chronic.parse(to)
			end

			# Create the banner
			banner = Banner.new
			banner.message = params[:message]

			# Determine the recurring day
			if every == true
				weekday = time.first.wday
				weekday = 7 if weekday == 0
				banner.recurring = weekday
			end

			# Banner date range
			if time.count > 1
				banner.start = time.first
				banner.stop = time.last
			else
				banner.start = time.first
			end

			if banner.save
				flash[:success] = "Banner successfully added."
			else
				flash[:error] = "Banner could not be created."
			end

			redirect_to request.path
		end
	end

	def delete_banner
		if Banner.find(params[:id]).destroy
			flash[:success] = "Banner was deleted successfully"
		else
			flash[:error] = "Banner could not be deleted"
		end

		redirect_to '/admin/banners'
	end

	def dismiss_banner
		cookies[:tioki_banner_dismissed] = {
			:value => true,
			:expires => 3.hours.from_now
		}

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
		if Follower.where("user_id = ?", self.current_user.id).count >= 3
			@followed = true
			@start_count += 1
		end

		#Join three groups
		if User_Group.where("user_id = ?", self.current_user.id).count >= 3
		@groups = true
		@start_count += 1
		end

		#Vouch 5 skills
		if VouchedSkill.where("voucher_id = ?" , self.current_user.id).count >= 5
		@vouched_skills = true
		@start_count += 1
		end

		#post to whiteboard
		if Whiteboard.where("whiteboards.slug = ?", 'share').first
		@whiteboard_post = true
		@start_count += 1
		end

		#Post a reply to discussion
		if Comment.where("commentable_type = 'Discussion' && comments.user_id = ?", self.current_user.id).first
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
		@invite_count = ConnectionInvite.where("user_id = ? && connection_invites.created_at > ?", self.current_user.id, TIOKI_BUCKS_START).count

		#two dollars per invite maxed at 42 dollars
		if @invite_count*2 > 42
			@tioki_bucks += 42
		else
			@tioki_bucks += @invite_count*2
		end

		if @start_count >= 5
			@tioki_bucks += 5
		end

		if !self.current_user.social_actions['facebook_connect'].nil?
			@tioki_bucks += 1
		end
		if !self.current_user.social_actions['twitter_connect'].nil?
			@tioki_bucks += 1
		end
		if !self.current_user.social_actions['tweet_about'].nil?
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

				# Save a redirect url for the return
				session[:linkedin_redirect] = params[:redirect] unless params[:redirect].nil?

				redirect_to client.request_token.authorize_url
			elsif params[:response] == 'no'
				redirect_to '/profile/'+self.current_user.slug
			end
		end
	end

	def get_started
		@tioki_bucks = 0

		#3 connections
		@connections = Connection.mine(:pending => false).count

		#follow three discussions
		@following = Follower.where("user_id = ?", self.current_user.id).count

		#Join three groups
		@groups = User_Group.where("user_id = ?", self.current_user.id).count

		#Vouch 5 skills
		@vouched_skills =  VouchedSkill.where("voucher_id = ?" , self.current_user.id).count

		#post to whiteboard
		@whiteboard_post =  Whiteboard.where("user_id = ? && whiteboards.slug = ?", self.current_user.id, 'share').first

		#Post a reply to discussion
		@comment =  Comment.where("commentable_type = 'Discussion' && comments.user_id = ?", self.current_user.id).first
	end

	def profile_stats
		@my_connections = Connection.mine(:pending => false).collect{ |connection| connection.not_me.id }

		@user = User.current

		# Get a listing of who has viewed this teacher (IN ALL TIME)
		@viewed = Analytic.
			where("slug = ? && tag = ?", "view_user_profile", @user.tag!).
			group('user_id').
			order('created_at DESC')

		# Get the dates to run the query by
		tomorrow = Time.now.tomorrow
		lasteight = Time.now - 8.weeks

		view_dates = Analytic.
			where("tag = ?  AND slug = ? AND created_at > ? AND created_at < ?",
			@user.tag!, "view_user_profile", lasteight, tomorrow).collect(&:created_at)

		time_now = Time.now
		@views = Array.new
		@labels = Array.new

		(1..8).each do |week|
			date1 = time_now - (56 - ( week - 1 ) * 7).days
			date2 = time_now - (56 - ( week * 7) ).days

			views_on_week = view_dates.count{ |date| date > date1 && date < date2 }
			@views  << [week, views_on_week]
			@labels << [week, "#{date1.month}/#{date1.day} - #{date2.month}/#{date2.day}"]
		end
	end
  
	# Profile About 
	def profile_about; profile(false); end
  
	# Profile Resume 
	def profile_resume; profile(false); end

	def profile_application; profile(false); end

	def profile_activity; profile(true); end

	def profile(whiteboard = true)

		@application = nil
		if params[:application] != nil
			@application = Application.find(params[:application])
			if @application.belongs_to_me(self.current_user)
			else
				@application = nil
			end
		end
		# Figure out whether to load a profile by slug or the current user.
		if !params[:slug].nil? && !params[:slug].empty?
			@user = User.find_by_slug(params[:slug])
		elsif !currentUser.new_record?
			@user = currentUser
		end

		# If no record is found 404 it
		raise HTTPStatus::NotFound if @user.nil?

		# Check if user is a guest
		@guest = false; if !params[:guest_pass].nil? && !params[:guest_pass].empty?
		@guest = params[:guest_pass].strip == @user.guest_code
		end

		# Check if user is connected to teacher or is self
		@self = false
		@connected = false
		if !currentUser.new_record? && @user.me?
			@connected = true
			@self = true
		elsif !currentUser.new_record? && currentUser.connected_to?(@user)
			@connected = true
		end

		# If the teacher could not be found then raise an exception
		raise ActiveRecord::RecordNotFound, "User profile could not found." if @user.nil?

		# Log that someone viewed this profile unless there is no teacher associated with the user or you are viewing your own profile
		if !currentUser.new_record? && !@user.me?
			self.log_analytic(:view_user_profile, "Someone viewed a user profile", @user)
		end

		if whiteboard
			# Get whiteboard activity
			@whiteboard = Array.new
			Whiteboard.where("user_id = ?", @user.id).order("created_at DESC").paginate(:per_page => 15, :page => params[:page]).each do |post|
				@post = post
				@whiteboard << render_to_string('whiteboards/profile_whiteboard', :layout => false)
			end
		end
			
		# If the there is currently a user logged in
		if !currentUser.new_record?
			@connection = currentUser.connection_to(@user)
			@pendingconnection = currentUser.connection_to(@user, true)
		end

		# Vouch referring teacher 
		if params[:invite_id]
			@invite = ConnectionInvite.find(params[:invite_id])
		end

		@grades = @user.grades.collect(&:name)
		@subjects = @user.subjects.collect(&:name)

		if @user.nil?
			redirect_to :root
			flash[:alert]  = "User was not found"
		else
			if whiteboard
				respond_to do |format|
					if currentUser.new_record? || (!@self && !@connected && @user.privacy_public[:whiteboard])
						format.html { redirect_to "/profile/#{@user.slug}/about"}
						format.json  { render :json => @teacher } # profile.json
					else
						format.html # profile_activity.html.erb
						format.json  { render :json => @teacher } # profile_activity.json
					end
				end
			end
		end
	end

	def more_groups
		@user = User.find_by_slug(params[:slug])
		group = render_to_string("users/more_groups", :layout => false)
		return render :json => group.to_json

	end

	def more_tech
		@user = User.find_by_slug(params[:slug].parameterize)
		tech = render_to_string("users/more_tech", :layout => false)
		return render :json => tech.to_json

	end

	def slug_availability
		slug = User.find_by_slug(params[:slug].parameterize)
		if !slug.nil? && slug != User.current
			return render :json => false
		else
			render :json => true
		end
	end

	# Upgrade account

	def upgrade
		if request.post?
			case params[:type]
			when 'recruiter'
				group = Group.new(params[:group])

				respond_to do |format|
					if group.save

						# Set permissions
						group.permissions = {
							:hidden => true,
							:private => true,
							:organization => true
						}

						# Create join row for users -> groups
						user_group = User_Group.new
						user_group.user_id = currentUser.id
						user_group.group_id = group.id
						user_group.save

						#Log into Analytics
						self.log_analytic(:organization_creation, "New organization was created.", group, [], :groups)

						# Add the first administrator
						user_group.permissions = {
							:member => true,
							:moderator => true,
							:administrator => true,
							:owner => true
						}

						# Return HTML or JSON
						format.html { redirect_to edit_group_path(group), notice: 'Organization was successfully created.' }
					else
						flash[:error] = "There was an error creating your organization"
						redirect_to :back
					end
				end
			end
		end
	end

	def temp
		if request.post?
			Whiteboard.createActivity('file', "testing uploading of files", '', params[:file])
		end
	end

	private

		def authenticate
			return true if !currentUser.new_record? && self.current_user.is_admin

			# If auth fail
			render :text => "Access Denied"
			return 401

		end
end
