class JobsController < ApplicationController
	before_filter :login_required, :except => ['index', 'show', 'job_referral', 'job_referral_email', 'preferences']
	before_filter :login_required_signup, :only => ['preferences']

	# Source the owner if applicable
	before_filter :source_owner, :only => [:index, :request_credits, :credit_request_email]
	
	# GET /jobs
	# GET /jobs.xml
	def index
		if @source.is_a?(Group)
			if @source.user_permissions.administrator || currentUser.is_admin
				respond_to do |format|
					format.html { manage; render :manage }
					format.json  { render :json => manage_status }
				end

				return
			else
				@group = @source
				@jobs = @group.jobs.where(:status => 'running').limit(@group.job_allowance)
				return render :group_jobs
			end
		end

		if @source.nil?
			# Deprecate job filter needs a replacement
			@subjects = Subject.all
			if params[:searchkey].present? || params[:location].present? || params[:employment] || params[:posttime]
				tup = SmartTuple.new(" AND ")


				tup << ['jobs.title LIKE ? OR jobs.description LIKE ? OR groups.name', "%#{params[:searchkey]}%", "%#{params[:searchkey]}%"] if params[:searchkey].present?

				tup << ["jobs_subjects.subject_id = ?", params[:subject]] if params[:subject].present?

				tup << ["employment_type = ?", params[:employment]] if params[:employment].present?

				tup << ["jobs.created_at > ?", Date.today- params[:posttime].to_f.days] if params[:posttime].present?

				if params[:location].present? && params[:location][:city].length > 0
					@groups = Group.near(params[:location][:city], params[:radius]).collect(&:id)

					if @groups.size == 0
						#will_paginate does not like nil objects or arrays so just 
						#giving it something it will not have an error on
						@jobs = Job.unscoped.
							is_active.near(params[:location][:city],
							               params[:radius]).
							               paginate(:page => params[:page],
							                        :order => 'updated_at DESC')
					else
						@jobs = Job.where(:group_id => @groups).
							      is_active.paginate(:page => params[:page],
							                         :joins => :group,
							                         :conditions => tup.compile,
							                         :order => 'updated_at DESC')
					end
				else
					@jobs = Job.is_active.paginate(
						:page => params[:page], 
						:joins => :group, 
						:conditions => tup.compile, 
						:order => 'updated_at DESC')
				end
			else
				@jobs = Job.is_active.paginate(:page => params[:page], :order => 'updated_at DESC')
			end
		else
			@jobs = @source.is_active.paginate(:page => params[:page], :order => 'updated_at DESC')
		end

		@title = "Jobs"

		respond_to do |format|
			format.html # index.html.erb
			format.json  { render :json => @jobs }
		end
	end
	
	# Review
	def auto_complete_search
		begin
			@items = Job.complete_for(params[:search])
		rescue ScopedSearch::QueryNotSupported => e
			@items = [{:error =>e.to_s}]
		end
		render :json => @items
	end
	
	# Review
	def apply
		@job = Job.find(params[:id])
		@job.apply(self.current_user.id)
		@application = Application.where('job_id = ? AND user_id = ?', @job.id, self.current_user.id).first
		@assets = Asset.where('job_id = ? AND user_id =?', @job.id, self.current_user.id).all
		@assets.each do |asset|
			asset.update_attribute(:application_id, @application.id)
		end
		
		respond_to do |format|
			if @application == nil  
			format.html { redirect_to @job, :notice => 'Application Removed.' }
			else 
			format.html { redirect_to @job, :notice => 'Application Successfully Submitted.' }
			end
		end
	end
	
	# Review
	def apply_confirmation
		@job = Job.find(params[:id])
		@user = User.find(self.current_user.id)
	end

	# Review
	def job_referral
		@job = Job.find(params[:id])
		
		if self.current_user != nil 
			 @teacher_user = self.current_user.id
		end
		
	end
	
	def job_referral_email
		@job = Job.find(params[:id])
		@referral = params[:referral]
	 
	 if self.current_user == nil
		 @teachername = @referral[:teachername]
	 else
		 @user = self.current_user
		 @teachername = @user.name 
	 end 
	 
		@name = @referral[:name]
		@email = @referral[:email]
		
		UserMailer.refer_job_email(@teachername, @job, @name, @email).deliver
		
		 respond_to do |format|
				format.html { redirect_to @job, :notice => 'Email Sent Successfully' }

		 end
		 
	end

	# GET /jobs/:id
	# GET /jobs/:id
	def show
		@job = Job.find(params[:id])
		if self.current_user
			@application = Application.where('job_id = ? AND user_id = ? AND submitted = 1', @job.id, self.current_user.id).first
		end
		
		respond_to do |format|
			if @job.active == true || @job.status == 'running' || @job.belongs_to_me(self.current_user) || @job.shared_to_me(self.current_user)
				format.html # show.html.erb
				format.json  { render :json => @job }
			else
				format.html { redirect_to :root, :notice => 'This posting is not currently available.' }
			end
		end
	end
	
	# Create a new job posting
	# Author: Kelly Lauren Summer Becker
	# GET /group/:group_id/jobs/new
	def new
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id])) || currentUser.is_admin
		@job = Job.new
		JobQuestion.new
		1.times { @job.job_questions.build }
		@counter = 1 

	end

	# Edit a job posting
	# Author: Kelly Lauren Summer Becker
	# GET /group/:group_id/jobs/:id/edit
	def edit
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id])) || currentUser.is_admin
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:id]))
		@counter = @job.job_questions.count
		if @counter == 0
			1.times { @job.job_questions.build }
			@counter = 1
		end
	end

	# create a new job posting
	# Author: Kelly Lauren Summer Becker
	# POST /group/:group_id/jobs
	def create

		# Make sure we have permissions to create the job
		group = Group.find(params[:group_id])
		raise SecurityTransgression if !group.user_permissions.administrator && !currentUser.is_admin

		@job = Job.new(params[:job])

		# New Organizations Vs. Old Organizations
		@job.longitude = group.longitude
		@job.latitude = group.latitude
		@job.group = group
		
		# Only allow a hard limit of jobs to be "running"
		if @job.status == 'running' && group.job_allowance <= group.jobs.where(:status => 'running').count
			flash[:error] = "You cannot create more running jobs without buying more packs"
			return redirect_to [group, :jobs]
		end


		# Attemp to save and return
		respond_to do |format|
			if @job.save

				@job.update_subjects(params[:subjects]) if params[:subjects]
				@job.update_grades(params[:grades]) if params[:grades]

				format.html {
					flash[:success] = "New job was successfully created."
					redirect_to [group, :jobs]
				}
				format.json { render json: @job }
			else
				format.html { redirect_to :back }
				format.json { render json: @job.errors, status => :unprocessable_entity }
			end
		end
	end

	# Update an existing job posting
	# Author: Kelly Lauren Summer Becker
	# POST /group/:group_id/jobs/:id
	def update
		@job = Job.find(params[:id])

		# Make sure we have permissions to update the job
		raise SecurityTransgression if @job.group.to_param != params[:group_id]
		raise SecurityTransgression if !@job.group.user_permissions.administrator && !currentUser.is_admin

		group = @job.group

		if params[:job][:status] == 'running' && group.job_allowance <= group.jobs.where(:status => 'running').count
			flash[:error] = "You must buy more job packs if you want to run more jobs"
			return redirect_to :back
		end

		# Attemp to save and return
		respond_to do |format|
			if @job.update_attributes(params[:job])


				@job.update_subjects(params[:subjects]) if params[:subjects]
				@job.update_grades(params[:grades]) if params[:grades]
				@job.update_question[:job_questions] if params[:job_questions]

				format.html {
					flash[:success] = "New job was successfully updates."
					redirect_to [group, :jobs]
				}
				format.json { render json: @job }
			else
				format.html { redirect_to :back }
				format.json { render json: @job.errors, status => :unprocessable_entity }
			end
		end
	end

	def attach
		@user = User.find_by_id(self.current_user.id)
		@user.new_asset_attributes = params[:asset]

		if @user.save_assets
			redirect_to :back, :notice => 'Attachment was successfully uploaded.'
		else
			redirect_to :back, :notice => 'Attachment could not be uploaded'
		end
	end

	def jobattachpost
		@job = Job.find_by_id(params[:id])
		@assets = @job.assets
		if request.post?
			@job.new_asset_attributes=params[:asset]

			if @job.save_assets
				redirect_to :back, :notice => 'Attachment was successfully uploaded.'
			else
				redirect_to :back, :notice => 'Attachment could not be uploaded'
			end
		end
	end

	def jobattachpurge
		@asset = Asset.find_by_id(params[:id])
		if @asset.job.belongs_to_me(self.current_user) || @asset.job.shared_to_me(self.current_user)
			@asset.destroy
		
			respond_to do |format|
			 format.html { redirect_to(:back, :notice => 'Attachment removed.') }
			 format.xml  { head :ok }
			end
		end
	end

	# DELETE /jobs/1
	# DELETE /jobs/1.xml
	def destroy
		@job = Job.find(params[:id])
		@job.cleanup
		@job.destroy

		respond_to do |format|
			format.html { redirect_to(:my_jobs) }
			format.xml  { head :ok }
		end
	end

	def manage
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@source) || currentUser.is_admin
		@jobs = @source.jobs
	end

	def manage_status
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id])) || currentUser.is_admin
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:job]))

		if @job.update_attribute(:status, params[:status])
			if params[:status] == "running"
				if !@job.notification_sent
					@job.delay.notify_educators
					@job.update_attribute(:notification_sent, true)
				end
			end
			return {:status => 'success'}
		else
			return {:status => 'error'}
		end
	end

	def request_credits
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@source)
		@jobs = @source.jobs
	end

	def credit_request_email
		@organizations = User.current.groups.my_permissions('administrator').organization

		# Get the post data key
		@request = params[:request]

		# Interpret the post data from the form
		@requested_number = @request[:requested_number]
		@credits_for_other_orgs = @request[:credits_for_other_orgs]

		# Get the current user if applicable
		@user = self.current_user 

		# Send out the email to the list of emails
		UserMailer.credit_request_email(@requested_number, @credits_for_other_orgs, @source, @user).deliver

		# Return user back to the home page 
		redirect_to :back, :notice => 'Request Sent. We will be in touch shortly!'
	end

	def preferences
		if currentUser.job_seeker
			@job_seeker = currentUser.job_seeker
		else
			@job_seeker = JobSeeker.new
		end

		if @job_seeker.subject_ids
			subject_ids = @job_seeker.subject_ids.split(",")
			@subjects = Subject.where(:id => subject_ids)
		end

		if @job_seeker.grade_ids
			grades_ids = @job_seeker.grade_ids.split(",")
			@grades = Grade.where(:id => grades_ids)
		end

		if request.post?
			if params[:job_seeker][:any_location]
				@job_seeker.any_location = true
					@job_seeker.location = nil
			else
				@job_seeker.any_location = false
				box = JobSeeker.seeking_location_box(params[:job_seeker][:location])

				if box
					@job_seeker.location = params[:job_seeker][:location]
					@job_seeker.box = box.join(",")
				else
					redirect_to :back, "Could not identify location."
				end
			end
			@job_seeker.grade_ids = params[:job_seeker][:grades]
			@job_seeker.subject_ids = params[:job_seeker][:subjects]
			@job_seeker.school_type = params[:job_seeker][:school_type]
			@job_seeker.recruitable = params[:job_seeker][:recruitable] == 'true'

			@job_seeker.save!
			self.log_analytic(:user_job_preferences, "User used job preferences",
			                  currentUser, [], :jobs)

			redirect_to jobs_url
		end
	end

	protected

	# Jobs source
	def source_owner
		unless params[:user_id].nil?
			ids = User.find(params[:user_id]).groups.select('`groups`.`id`').organization.my_permissions(:administrator).map(&:id)
			@source = Job.joins(:group).where('`groups`.`id` IN (?)', ids)
			@org = true
		end

		# Source the group
		unless params[:group_id].nil?
			@source = Group.find(params[:group_id])
		end
	end
end
