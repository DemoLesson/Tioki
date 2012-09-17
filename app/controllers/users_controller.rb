class UsersController < ApplicationController
	before_filter :login_required, :only=>['welcome', 'change_password', 'choose_stored', 'edit']
	USER_ID, PASSWORD = "andreas", "dl2012"
	before_filter :authenticate, :only => [ :fetch_code, :user_list, :school_user_list, :teacher_user_list, :deactivated_user_list, :organization_user_list,:manage ]

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

				# Create the teacher record on the user
				self.create_teacher_and_redirect false

				# Notice the signup was successful
				flash[:notice] = "Signup successful"

				# Set to splash for analytics
				session[:_ak] = "splash"

				# Redirect to the wizard
				return redirect_to '/welcome_wizard?x=step2'

			# If there were any errors flash them and send :root
			else
				flash[:notice] = @user.errors.full_messages.to_sentence
				return redirect_to :root
			end
		end

		redirect_to :root
	end

	# Json register
	def create_json
		@user = User.new(params[:user])
		@success = ""

		if request.post?
			if @user.save
				session[:user] = User.authenticate(@user.email, @user.password)
				session[:user] = @user.id
				self.log_analytic(:user_signup, "New user signed up.", @user)

				data = {"type" => "success", "message" => "Signup successful"}
				self.create_teacher_and_redirect(false)
				return render :json => data
			else

				data = {"type" => "error", "message" => @user.errors.full_messages.to_sentence}
				return render :json => data
			end
		end
	end

	def create_admin
		@user = User.new(:name => params[:name], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
		@success = ""
		if @user.save
			session[:user] = User.authenticate(@user.email, @user.password)
			@school = School.new(:user => @user, :name=> params[:schoolname], :map_address => '100 W 1st St', :map_city => 'Los Angeles', :map_state => 5, :map_zip => '90012', :gmaps => 1); 
			if @school.save
				o=Organization.create
				o.update_attribute(:owned_by, @user.id)
				o.update_attribute(:name, params[:schoolname])
				UserMailer.school_signup_email(params[:name], params[:schoolname], params[:email], params[:phonenumber], @school).deliver
				self.current_user.default_home = school_path(self.current_user.school.id)
				self.log_analytic(:organization_signup, "New organization signed up.", @user)
				redirect_to :school_thankyou, :notice => "Signup successful!"
			else
				@user.destroy
					flash[:notice] = "Signup unsuccessful."
			end
		else
			flash[:notice] = "Signup unsuccessful."
			redirect_to "/"
		end
	end
	
	def verify
		User.verify!(params[:user_id], params[:verification_code])
		redirect_to_stored
	end

	def login
		redirect_to :root unless User.current.nil?
		
		if request.post?
			if session[:user] = User.authenticate(params[:user][:email], params[:user][:password])
				self.log_analytic(:user_logged_in, "User logged in.")
				self.current_user.update_login_count
				logger.info "Login successful"

				if params[:remember_me]
					login_token = LoginToken.generate_token_for!(session[:user])
					cookies[:login_token_user] = { :value => login_token.user_id, :expires => login_token.expires_at }
					cookies[:login_token_value] = { :value => login_token.token_value, :expires => login_token.expires_at }
				end
				redirect_to_stored
			else
			#logger.info "Login unsuccessful"
				flash[:notice] = "Login unsuccessful"
			end
		end
	end

	# Login and use JSON for all results
	def login_json
		if request.post?
			if session[:user] = User.authenticate(params[:email], params[:password])
				self.log_analytic(:user_logged_in, "User logged in.")
				self.current_user.update_login_count
				logger.info "Login successful"

				if params[:remember_me]
					login_token = LoginToken.generate_token_for!(session[:user])
					cookies[:login_token_user] = { :value => login_token.user_id, :expires => login_token.expires_at }
					cookies[:login_token_value] = { :value => login_token.token_value, :expires => login_token.expires_at }
				end

				data = {"type" => "success", "message" => "Login successful"}
				return render :json => data
			else
				data = {"type" => "error", "message" => "Login unsuccessful"}
				return render :json => data
			end
		end
	end
	
	def choose_stored
		if request.post?
			if params[:role] == 'teacher'
				self.current_user.create_teacher
				self.current_user.default_home = teacher_path(self.current_user.teacher.id)
				UserMailer.teacher_welcome_email(self.current_user).deliver
				
				redirect_to current_user.default_home
			elsif params[:role] == 'school'
				self.current_user.create_school
				self.current_user.default_home = school_path(self.current_user.school.id)
				redirect_to :root
				#redirect_to :root, :notice => 'Thank you for signing up. Please contact our support team at support@demolesson.com to start posting jobs.'
			end
		end
	end

		def create_teacher_and_redirect(redir = true)
			self.current_user.create_teacher
			
			UserMailer.teacher_welcome_email(self.current_user).deliver

			# If we have a referer in the creation process
			# then auto connect the other teacher to the new one
			if session.has_key?(:_referer)

				# Redirect to the connections controller and add the referer
				redirect_to '/connections/add_and_redir?user_id=' + session[:_referer].to_s + '&redir=' + teacher_path(self.current_user.teacher.id) if redir
			else

				# Redirect to the teacher path since we did not have a referer
				redirect_to teacher_path(self.current_user.teacher.id) if redir
			end
		end

	#  def choose_stored
	#    if request.post?
	#      if params[:role] == 'teacher'
	#        self.current_user.create_teacher
	#        self.current_user.default_home = teacher_path(self.current_user.teacher.id)
	#        UserMailer.teacher_welcome_email(self.current_user).deliver
	#        
	#        redirect_to current_user.default_home
	#      elsif params[:role] == 'school'
	#	      #self.current_user.create_school
	#        #self.current_user.default_home = school_path(self.current_user.school.id)
	#        redirect_to :root, :notice => 'Thank you for signing up. Please contact our support team at support@demolesson.com to start posting jobs.'
	#      end
	#    end
	#  end

	def logout
		User.current = nil
		session[:user] = nil
		flash[:notice] = 'You\'ve been logged out.'
		login_token = LoginToken.find_by_user_id(cookies[:login_token_user])
		if login_token
			cookies[:login_token_user] = { :value => nil, :expires => Time.new - 1.day }
			cookies[:login_token_value] = { :value => nil, :expires => Time.new - 1.day }
			LoginToken.delete(login_token.id)
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

	def change_password
		@user=session[:user]
		@message = ""
		if request.post?
			@user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
			if @user.save
				self.log_analytic(:user_changed_password, "A user changed their password.")
				@message = "Password Changed"
			end
		end
	end

	def show
		if self.current_user.nil?
			redirect_to :action=>'login'
		# elsif self.current_user.teacher
		#       redirect_to :controller=>'teachers', :action=>'edit', :id => self.current_user.teacher.id
		#     elsif self.current_user.school
		#       redirect_to :controller=>'schools', :action=>'edit', :id => self.current_user.school.id
		# else
		#  logger.info(self.current_user.inspect)
		#  redirect_to :controller=>'users', :action=>'select_type'
		else
			@user = User.find(params[:id])
			@school = School.find_by_owned_by(@user.id, :limit => 1)
			@teacher = Teacher.find_by_user_id(@user.id, :limit => 1)
			
			respond_to do |format|
				format.html
			end
		end
	end

	def select_type
		@user = current_user
		# render a selection page
	end
	
	def edit
		@user = User.find(self.current_user.id)
	end

	def accounts
		@organization = self.current_user.organization
		if self.current_user.is_shared
			u=SharedUsers.find(:first,:conditions => { :user_id => self.current_user.id})
			@user=User.find(u.owned_by)
		else
			@user=self.current_user
		end
		if self.current_user.is_shared
			sharedschool = SharedUsers.find(:first, :conditions => {:user_id => self.current_user.id})
			@members = SharedUsers.find(:all, :conditions => { :owned_by => sharedschool.owned_by})
		else
			@members = SharedUsers.find(:all, :conditions => { :owned_by => self.current_user.id})
		end
	end
	
	def update
          @user=self.current_user
          if !(params[:user][:avatar].content_type.include? "image")
            redirect_to :back, :notice => "The file was not an image."
          else
            #move tempoary file created by uploader 
            #to a file that won't disapper after the completion of the request
            directory = Rails.root.join('public/uploads')
            path = File.join(directory, params[:user][:avatar].original_filename)
            File.open(path, "w+b") {|f| f.write(params[:user][:avatar].read) }
            @user.update_attribute(:temp_img_name, '/uploads/'+params[:user][:avatar].original_filename)
            @user.update_attribute(:original_name,  params[:user][:avatar].original_filename)
            #redirect_to :crop_temp, :notice => "Successfully uploaded file"
            respond_to do |format|
              format.js
            end
          end
	end

        def crop_temp
          @user=self.current_user
          if @user.temp_img_name == nil
            redirect_to :back, :notice => "Could not find an uploaded file."
          end
        end

        def crop_image_temp
          @user = self.current_user
          orig_img = Magick::ImageList.new(Rails.root.join('public'+@user.temp_img_name))
          if(params[:user][:crop_x].present? && params[:user][:crop_y].present? && params[:user][:crop_w].present? && params[:user][:crop_h].present?)

                  args= [params[:user][:crop_x].to_i,params[:user][:crop_y].to_i,params[:user][:crop_w].to_i,params[:user][:crop_h].to_i]

                  orig_img.crop!(*args)
                else
                  #crop values have not been set, just resize to fit 1:1 aspect ratio
                  #the size of the image will be whatever side is smaller
                  if orig_img.rows > orig_img.columns
                    orig_img.resize_to_fill!(orig_img.columns, orig_img.columns)
                  else
                    orig_img.resize_to_fill!(orig_img.rows, orig_img.rows)
                  end
                end
                #Create temp file in order to save the cropped image for later saving to amazon s3
                tmp_img=Tempfile.new(@user.original_name, Rails.root.join('tmp'))

                #Set file to binary write, otherwise an attempt to convert from ascii 8-bit to UTF-8 will occur
                tmp_img.binmode
                orig_img.format="jpeg"
                tmp_img.write(orig_img.to_blob)
                @user.update_attribute(:avatar, tmp_img)
                tmp_img.close
		redirect_to :root, :notice => "Image changed successfully."
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
                    orig_img.resize_to_fill!(orig_img.rows, orig_img.rows)
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
			format.html { redirect_to @user, :notice => action }
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

		# Maybe think about making this code more dry by creating a update function using a ruby hash
		@user.update_attribute(:emailsubscription, params[:user][:emailsubscription])
		@user.update_attribute(:emaileventreminder, params[:user][:emaileventreminder])
		@user.update_attribute(:emaileventapproved, params[:user][:emaileventapproved])
		self.log_analytic(:user_changed_email_settings, "A user changed their email settings.")

		respond_to do |format|
			format.html { redirect_to :root, :notice => "You have updated your email settings." }
		end
	end

	def change_org_info
		@organization = self.current_user.organization
		if self.current_user.is_shared
			u=SharedUsers.find(:first,:conditions => { :user_id => self.current_user.id})
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
		@users = User.find(:all, :order => 'created_at DESC')
		@teachercounter = 0
		@schoolcounter = 0
		@schoolsnumber = 0
		respond_to do |format|
			format.html { render :user_list }
		end
	end
	
	def teacher_user_list
		if params[:tname]
			@users = User.find :all, :conditions => ['name LIKE ?', "%#{params[:tname]}%"],
				:order => "created_at DESC"
		else
			@users = User.find :all, :order => "created_at DESC"
		end
		@users=@users.reject{ |user| user.teacher == nil }
		if params[:vid]
			@users=@users.reject{ |user| user.videos.count == 0 }
		end
		if params[:applied]
			@users=@users.reject{|user| user.applications.count == 0}
		end
		@usercount = 0
		@videos = 0
		@users.each do |user|
			@usercount+=1
			if user.teacher.videos.count != 0
				@videos += 1
			end
		end
		@users=@users.paginate :page => params[:page], :per_page => 100
		
		@stats = []
		@stats.push({:name => 'Registered Users', :value => User.count})
		@stats.push({:name => 'Videos Uploaded', :value => @videos})
		@stats.push({:name => 'Number of Teachers', :value => @usercount})
		
		respond_to do |format|
			format.html { render :teacher_user_list }
		end
	end

	def deactivated_user_list
		if request.post?
			@user = User.unscoped.find(params[:user])
			@user.update_attribute(:deleted_at, nil)
		end
		@users = User.unscoped.find(:all)
		@users=@users.reject { |user| user.deleted_at == nil }
		
		@usercount = @users.count
		@teachercount = @users.reject { |user| user.teacher.nil? }.count
		@admincount = @users.reject { |user| user.teacher }.count

		@stats = []
		@stats.push({:name => 'Deactivated Users', :value => @users.count})
		@stats.push({:name => 'Deactivated Teachers', :value => @teachercount})
		@stats.push({:name => 'Deactivated Admins', :value => @admincount})

		@users=@users.paginate :page => params[:page], :per_page => 100
	end

	def school_user_list
		if request.post?
			user = User.new(:first_name => params[:contact_first],
											:last_name => params[:contact_last],
											:email => params[:email],
											:password => params[:pass])
			if user.save
				school = School.new(:user => user, :name=> params[:name], :school_type=> params[:school_type], :map_address => '100 W 1st St', :map_city => 'Los Angeles', :map_state => 5, :map_zip => '90012', :gmaps => 1); 
				if school.save
					o=Organization.create
					o.update_attribute(:owned_by, user.id)

					flash[:notice] = "The account was successfully created"
				else
					user.destroy
					flash[:notice] = "The account school could not be created"
				end
			else
				flash[:notice] = "The account could not be created."
			end
		end
		if params[:orgname] || params[:contactname] || params[:emailaddress]
			#The default scope for schools is currently joined with users
			#so I can select rows from the users table
			@schools = School.find :all,
				:conditions => ['schools.name LIKE ? AND users.name LIKE ? AND users.email LIKE ?', "%#{params[:orgname]}%", "%#{params[:contactname]}%", "%#{params[:emailaddress]}%"],
				:order => "created_at DESC"
		else
			@schools = School.find :all,
				:order => "created_at DESC"
		end
		#number of shared users+admins that created the orginal accounts
		#Full admins+Limited admins+organizations
		@admincount = SharedUsers.count+Organization.count
		@schools=@schools.paginate :per_page => 100, :page => params[:page]

		#count the total of applicants and jobs instead of based on what is searched
		@jobcount=0
		@applicants = 0
		School.all.each do |school|
			user = User.find(school.owned_by) 
			@jobcount+=school.jobs.count
			school.jobs.each do |job| 
				@applicants = @applicants + job.applications.count 
			end
		end

		@stats = []
		@stats.push({:name => 'Total Schools', :value => School.count})
		@stats.push({:name => 'Total Jobs', :value => @jobcount})
		@stats.push({:name => 'Total Applicants', :value => @applicants})
	end

	def organization_user_list
		if params[:orgname]
			@organizations=Organization.all
			#Since the names we can select can be eitheir the organization or the name of the first school instead of using ActiveRecord for selection, reject is used
			@organizations=@organizations.select { |organization| organization.oname.downcase.include?(params[:orgname])} 
			@organizations=@organizations.paginate :page => params[:page], :per_page => 25
		else
			@organizations=Organization.paginate :page => params[:page], :per_page => 25
		end
		@stats = []
		@stats.push({:name => 'Organizations', :value => Organization.count})
		@stats.push({:name => 'Administrators', :value => User.find(:all).reject { |user| user.teacher }.count})
	end

	def manage
		@schools = School.find(:all, :conditions => { :owned_by => params[:id] })
		@organization = Organization.find(:first, :conditions => { :owned_by => params[:id] })
		shared=SharedUsers.find(:all, :conditions => { :owned_by => params[:id]}).collect(&:user_id)
		@members=User.find(shared)
		if request.post?
			if self.current_user.is_limited
				redirect_to :back, :notice => 'You are not authorized to do this action.'
				return
			end
			@organization.update_attributes(:name => params[:name], :job_allowance => params[:job_allowance], :admin_allowance => params[:admin_allowance], :school_allowance => params[:school_allowance])
			redirect_to :schoollist
		end
	end

	def edit_member
		@user = User.find(params[:id])
		@schools = self.current_user.schools 
		if request.post?
			if self.current_user.is_limited
				redirect_to :back, :notice => 'You are not authorized to do this action.'
				return
			end
			@user.update_attributes(:name => params[:name], :email => params[:email])
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
			@user= User.new(:name => params[:name], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])

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
				flash[:notice] = "User could not be created"
			end
		end
	end

	def crop
		@user=self.current_user
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

	private
	def authenticate
		return true if !self.current_user.nil? && self.current_user.is_admin

		# If auth fail
		render :text => "Access Denied"
		return 401

		# Block old HTTP Auth
		#authenticate_or_request_with_http_basic do |id, password| 
		#  id == USER_ID && password == PASSWORD
		#end
	end
end

