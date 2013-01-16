class JobsController < ApplicationController
 	# Deprecate
	before_filter :login_required, :except => ['index', 'show', 'job_referral', 'job_referral_email']

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
			if params[:subject].present? || params[:school_type].present? || params[:grade_level].present? || params[:calendar].present? || params[:employment].present? || params[:special_needs].present? || params[:searchkey].present? || params[:location].present?
				tup = SmartTuple.new(" AND ")

				#tup << ["schools.map_zip = ?", params[:zipcode][:code]] if params[:zipcode][:code].present?

				tup << ['jobs.title LIKE ? OR jobs.description LIKE ?', "%#{params[:searchkey]}%", "%#{params[:searchkey]}%"] if params[:searchkey].present?

				tup << ["jobs_subjects.subject_id = ?", params[:subject]] if params[:subject].present?

				# On KVPairs Now
				# Review
				#tup << ["schools.school_type = ?", params[:school_type]] if params[:school_type].present?
				#tup << ["schools.grades = ?", params[:grade_level]] if params[:grade_level].present?
				#tup << ["schools.calendar = ?", params[:calendar]] if params[:calendar].present?

				tup << ["employment_type = ?", params[:employment]] if params[:employment].present?

				tup << ["special_needs = ?", params[:special_needs]] if params[:special_needs].present?

				tup << ["jobs.created_at > ?", Date.today- params[:posttime].to_f.days] if params[:posttime].present?

				if params[:location].present? && params[:location][:city].length > 0
					@schools = School.near(params[:location][:city], params[:radius]).collect(&:id)

					if @schools.size == 0
						#will_paginate does not like nil objects or arrays so just giving it something it will not have an error on
						@jobs = Job.unscoped.is_active.near(params[:location][:city], params[:radius]).paginate(:page => params[:page], :order => 'updated_at DESC')
					else
						if params[:subject].present?
							@jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :joins => [:school, :subjects],:conditions => tup.compile, :order => 'updated_at DESC')
						else
							@jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :joins => :school,:conditions => tup.compile, :order => 'updated_at DESC')
						end
					end
				else
					if params[:subject].present?
						@jobs = Job.is_active.paginate(:page => params[:page], :joins => [:school, :subjects], :conditions => tup.compile, :order => 'updated_at DESC')
					else
						@jobs = Job.is_active.paginate(:page => params[:page], :joins => :school, :conditions => tup.compile, :order => 'updated_at DESC')
					end
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
		if self.current_user == nil
			# do nothing
		else
			if self.current_user != nil
				@application = Application.where('job_id = ? AND user_id = ? AND submitted = 1', @job.id, self.current_user.id).first
			end
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
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id]))
		@job = Job.new
	end

	# Edit a job posting
	# Author: Kelly Lauren Summer Becker
	# GET /group/:group_id/jobs/:id/edit
	def edit
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id])) || currentUser.is_admin
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:id]))
	end

	# create a new job posting
	# Author: Kelly Lauren Summer Becker
	# POST /group/:group_id/jobs
	def create

		# Make sure we have permissions to create the job
		group = Group.find(params[:group_id])
		raise SecurityTransgression if !group.user_permissions.administrator

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

				# Update the subjects with new parameters
				@job.update_subjects(params[:subjects]) if params[:subjects]

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

				# Update the subjects with new parameters
				@job.update_subjects(params[:subjects]) if params[:subjects]

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
		params[:asset][:assetType]=1
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
		@assets= Asset.where('job_id = ? AND assetType = ?', params[:id], 0).all
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
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:group_id]))
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:job]))

		if @job.update_attribute(:status, params[:status])
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
