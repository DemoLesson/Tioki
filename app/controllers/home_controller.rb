class HomeController < ApplicationController

	def index

		# If logged in then load a dashboard
		if !currentUser.new_record?

			# Current user
			@user = currentUser

			if @user.dashboard == 'recruiter'

				# All your organizations
				@organizations = @user.groups.organization

				# All the jobs of all your organizations
				@jobs = @organizations.all.collect{|x|x.jobs}.flatten

				# How many administrators exist across all your orgs
				@administrators = @organizations.all.collect{|x|x.users(:administrator).count}.inject(0){|t,x|t+x}

				# Total amount of interviews you have ever had across all your orgs
				@interviews = @jobs.inject(0){|t,x|t+x.interviews.count}

				# Total amount of applicants you have ever had across all your orgs
				@applicants = @jobs.inject(0){|t,x|t+x.new_applicants.count}
			else

				# Get whiteboard activity
				@whiteboard = Array.new
				Whiteboard.getActivity(true, :exclude => :connection).paginate(:per_page => 15, :page => params[:page]).each do |post|
					@post = post
					@whiteboard << render_to_string('whiteboards/show', :layout => false)
				end

				# Prepare the new connections bin
				connections = Whiteboard.getActivity(true, :restrict => :connection).limit(6).all.recurse{|w| w.getModels}
				@post = {:slug => 'connections', :data => connections}
				@whiteboard.unshift(render_to_string('whiteboards/show', :layout => false))

				# Get a list of all my skills and a list of all my connections
				skill_claims = Skill.where('`skills`.`id` IN (?)', self.current_user.skill_claims.collect!{|x| x.skill_id})
				skill_claims = skill_claims.select('`skill_claims`.*').joins(:skill_claims).to_sql
				my_connections = @user.connections.collect{|x| x.not_me_id}

				# Create / Run the Query
				joins = ["RIGHT JOIN (#{skill_claims}) as `tmp` ON `users`.`id` = `tmp`.`user_id`"]
				joins << 'LEFT JOIN `connections` ON `users`.`id` = `connections`.`user_id` OR `users`.`id` = `connections`.`owned_by`'
				@suggested_connections = User.joins(joins.join(" ")).where("`users`.`avatar_file_size` IS NOT NULL")
				@suggested_connections = @suggested_connections.where("`connections`.`owned_by` NOT IN (?)", my_connections)
				@suggested_connections = @suggested_connections.where("`connections`.`user_id` NOT IN (?)", my_connections)
				@suggested_connections = @suggested_connections.select('`users`.*').group('`users`.`id`').limit(3).order('(RAND() / COUNT(*) * 2)')

				@latest_dl = Whiteboard.where("`slug` = ?", 'video_upload').order('`created_at`').limit(3)

				@pendingcount = self.current_user.pending_connections.count

				@profile_views = self.get_analytics(:view_user_profile, self.current_user, nil, nil, true).count

				@jobs = Job.find(:all, :conditions => ['active = ?', true], :limit => 4, :order => 'created_at DESC')

				@discussions = Discussion.find(:all, :limit => 3, :order => 'created_at DESC')

				@featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')

				@interviews = self.current_user.interviews
			end
		end

		respond_to do |format|
			format.html # beta.html.erb
		end
	end
	
	def site_referral
		unless self.current_user.nil?
			name = self.current_user.name
		else
			name = "[name]"
		end

		@default_message = "I'd love to add you to my professional teaching network at DemoLesson. We can connect and the profile is super easy to make. Check it out!\n\n-#{name}"
	end

	def school_signup
		# Creating Free School Account
		if request.post?

			user = User.new(
				:first_name => params[:contact_first],
				:last_name => params[:contact_last],
				:email => params[:email],
				:password => params[:pass],
				:password_confirmation => params[:confirm_pass]
			)

			if user.save
				session[:user] = User.authenticate(user.email, user.password)
				group = Group.new
				group.name = params[:name]

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

					JobPack.create(
						:group => group,
						:jobs => 1,
						:expiration => Time.now + 60.days,
						:inception => Time.now,
						:refunded => 0,
						:amount => 0,
						:additional_data => {:freebie => true}.to_json)
					respond_to do |format|
						format.html { redirect_to edit_group_path(group), notice: 'Organization was successfully created.' }
					end
				end
			else
				flash[:error] = "There was an error creating your organization"
			end
		end
	end

	def school_signup_email
		#Emailing Us About The New School Account
		@signup = params[:signup]
		@name = @signup[:name]
		@schoolname = @signup[:schoolname]
		@email = @signup[:email]
		@phonenumber = @signup[:phonenumber]

		UserMailer.school_signup_email(@name, @schoolname, @email, @phonenumber).deliver

		respond_to do |format|
			format.html { redirect_to :school_thankyou}
		end
	end

	def site_referral_email
		if params[:referral][:teachername].nil? || params[:referral][:teachername].empty?
			flash[:notice] = "Name is required"
			return redirect_to '/site_referral'
		end

		if params[:referral][:emails].nil? || params[:referral][:emails].empty?
			flash[:notice] = "Email is required"
			return redirect_to '/site_referral'
		end

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
		UserMailer.refer_site_email(@teachername, @emails, @message, user).deliver

		# Return user back to the home page 
		respond_to do |format|
			format.html { redirect_to "http://www.tioki.com", :notice => 'Email Sent Successfully' }
		end
	end

	def whiteboard_share
		redirect_to :root if self.current_user.nil?
		if params[:message].present?
			whiteboard = Whiteboard.createActivity('share', params[:message], '', {"deleteable" => true})
			if self.current_user.twitter_auth? && params[:share_on_twitter]

				if params[:share_on_facebook]
					# need to share on both platforms
					# Store this fact in session as it may need to go
					# through a callback, so just can't pass as params
					session[:share_on_facebook] = true
				end
				
				return redirect_to whiteboard_share_twitter_authentications_url(:whiteboard_id => whiteboard.id)
			elsif params[:share_on_twitter]

				session[:whiteboard_id] = whiteboard.id
				return redirect_to "/twitter_auth?twitter_action=whiteboard_auth"
			elsif self.current_user.facebook_auth? && params[:share_on_facebook]

				session[:whiteboard_id] = whiteboard.id
				return redirect_to whiteboard_share_facebook_authentications_url(:whiteboard_id => whiteboard.id)
			elsif params[:share_on_facebook]

				session[:whiteboard_id] = whiteboard.id
				return redirect_to facebook_auth_authentications_url(:facebook_action => "whiteboard_auth")
			end
		end

		redirect_to :back
	end

	def whiteboard_rmv
		w = Whiteboard.find(params[:post])
		redirect_to :root if self.current_user.nil? || (w.user != self.current_user && !self.current_user.is_admin)
		w.destroy
        redirect_to :root
	end
end
