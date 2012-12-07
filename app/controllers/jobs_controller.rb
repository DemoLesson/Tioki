class JobsController < ApplicationController
	before_filter :login_required, :except => ['index', 'show', 'job_referral', 'job_referral_email']
	
	# GET /jobs
	# GET /jobs.xml
	def index
		puts params
		params.each do |key,value|
			Rails.logger.warn "Param #{key}: #{value}"
		end
		
		@subjects = Subject.all
		if params[:subject].present? || params[:school_type].present? || params[:grade_level].present? || params[:calendar].present? || params[:employment].present? || params[:special_needs].present? || params[:searchkey].present? || params[:location].present?
			tup = SmartTuple.new(" AND ")

			#tup << ["schools.map_zip = ?", params[:zipcode][:code]] if params[:zipcode][:code].present?
			logger.debug "test1"
			tup << ['jobs.title LIKE ? OR jobs.description LIKE ?', "%#{params[:searchkey]}%", "%#{params[:searchkey]}%"] if params[:searchkey].present?

			tup << ["jobs_subjects.subject_id = ?", params[:subject]] if params[:subject].present?

			tup << ["schools.school_type = ?", params[:school_type]] if params[:school_type].present?

			tup << ["schools.grades = ?", params[:grade_level]] if params[:grade_level].present?

			tup << ["schools.calendar = ?", params[:calendar]] if params[:calendar].present?

			tup << ["employment_type = ?", params[:employment]] if params[:employment].present?

			tup << ["special_needs = ?", params[:special_needs]] if params[:special_needs].present?

			tup << ["jobs.created_at > ?", Date.today- params[:posttime].to_f.days] if params[:posttime].present?

			if params[:location].present? && params[:location][:city].length > 0
				@schools = School.near(params[:location][:city], params[:radius]).collect(&:id)

				if @schools.size == 0
					#will_paginate does not like nil objects or arrays so just giving it something it will not have an error on
					@jobs = Job.unscoped.is_active.near(params[:location][:city], params[:radius]).paginate(:page => params[:page], :order => 'created_at DESC')
				else
					if params[:subject].present?
						@jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :joins => [:school, :subjects],:conditions => tup.compile, :order => 'created_at DESC')
					else
						@jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :joins => :school,:conditions => tup.compile, :order => 'created_at DESC')
					end
				end
			else
				if params[:subject].present?
					@jobs = Job.is_active.paginate(:page => params[:page], :joins => [:school, :subjects], :conditions => tup.compile, :order => 'created_at DESC')
				else
					@jobs = Job.is_active.paginate(:page => params[:page], :joins => :school, :conditions => tup.compile, :order => 'created_at DESC')
				end
			end
		else
			@jobs = Job.is_active.paginate(:page => params[:page], :order => 'created_at DESC')
		end
		
		@title = "Jobs"

		respond_to do |format|
			format.html # index.html.erb
			format.json  { render :json => @jobs }
		end
	end
	
	def auto_complete_search
		begin
			@items = Job.complete_for(params[:search])
		rescue ScopedSearch::QueryNotSupported => e
			@items = [{:error =>e.to_s}]
		end
		render :json => @items
	end
	
	def apply
		@job = Job.find(params[:id])
		@job.apply(self.current_user.id)
		@application = Application.find(:first, :conditions => ['job_id = ? AND user_id = ?', @job.id, self.current_user.id])
		@assets=Asset.find(:all, :conditions => ['job_id = ? AND user_id =?', @job.id, self.current_user.id])
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
	
	def apply_confirmation
		@job = Job.find(params[:id])
		@user = User.find(self.current_user.id)
	end

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
		 @teacher_user = self.current_user.id
		 @teacher = User.find(@teacher_user)
		 @teacher_user = User.find(@teacher.user_id)  
		 @teachername = @teacher_user.name 
	 end 
	 
		@name = @referral[:name]
		@email = @referral[:email]
		
		UserMailer.refer_job_email(@teachername, @job, @name, @email).deliver
		
		 respond_to do |format|
				format.html { redirect_to @job, :notice => 'Email Sent Successfully' }

		 end
		 
	end
	
	def kipp_apply
		@job = Job.find(params[:id])
		if (params.has_key?(:job))
			@passcode = params[:job][:passcode]
		else
			@passcode = ''
		end
			
		respond_to do |format|
			if @passcode != nil
				if @passcode == @job.passcode
					@job.apply(self.current_user.id)
					format.html { redirect_to @job, :notice => 'Application successful.' }
				else
					format.html
				end
			else
				format.html
			end
		end
	end

	def my_jobs
		if params[:school_id]
			@school = School.find(params[:school_id])
		else
			if(self.current_user.school != nil)
				@school = School.find(self.current_user.school)
			else
				@school = School.find(self.current_user.sharedschool)
			end
		end  
		@jobs = Job.paginate(:page => params[:page], :conditions => ['school_id = ?', @school.id])
		@user = self.current_user

		respond_to do |format|
			format.html # index.html.erb
			format.json  { render :json => @jobs }
		end
	end

	# GET /jobs/1
	# GET /jobs/1.xml
	def show
		@job = Job.find(params[:id])
		if self.current_user == nil
			# do nothing
		else
			if self.current_user != nil
				@application = Application.find(:first, :conditions => ['job_id = ? AND user_id = ?', @job.id, self.current_user.id])
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

	# GET /jobs/new
	# GET /jobs/new.xml
	def new
		@job = Job.new
		@subjects = Subject.all
		3.times { @job.assets.build }

		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @job }
		end
	end

	# GET /jobs/1/edit
	def edit
		@job = Job.find(params[:id])
		@subjects = Subject.all
		3.times { @job.assets.build }

		# Upgraded process
		if !@job.group_id.nil?
			raise HTTPStatus::Unauthorized if !@job.group.user_permissions['administrator']
		# Old processs
		else
			respond_to do |format|
				if @job.belongs_to_me(self.current_user) || @job.shared_to_me(self.current_user) 
					format.html
				else
					format.html { redirect_to :root, :notice => 'Unauthorized' }
				end
			end
		end
	end

	# POST /jobs
	# POST /jobs.xml
	def create
		@subjects = Subject.all
		@job = Job.new(params[:job])

		# New Organizations Vs. Old Organizations
		if !params[:group_id].nil? && !params[:group_id].empty?
			@job.group_id = params[:group_id]
			
			# Only allow a hard limit of jobs to be "running"
			@org = Group.find(params[:group_id])
			if @job.status == 'running' && @org.job_allowance <= @org.jobs.where(:status => 'running').count
				flash[:error] = "You cannot create more running jobs without buying more packs"
				return redirect_to "/jobs/manage/#{@org.id}"
			end

			if @job.save
				if params[:subjects]
					@job.update_subjects(params[:subjects])
				end

				flash[:success] = "New job was successfully created."
				return redirect_to "/jobs/manage/#{@org.id}"
			end
		else
			@job.school_id = params[:school_id]
			@job.latitude = @job.school.latitude
			@job.longitude = @job.school.longitude

			if @job.belongs_to_me(self.current_user) == true  || @job.shared_to_me(self.current_user)
				count = self.current_user.organization.totaljobs
				if self.current_user.organization.job_allowance <= count
					redirect_to :root, :notice => 'Your current job allowance is too small to create this job. Please contact support in order to increase it.'
					return
				end

				if @job.save
					self.current_user.organization.update_attribute(:totaljobs, count + 1)

					if params[:subjects]
						@job.update_subjects(params[:subjects])
					end

					return redirect_to @job, :notice => 'Job was successfully created.'
				else
					return render :action => "new"
				end
			else
				format.html { redirect_to :root, :notice => 'Unauthorized' }
			end
		end
	end

	# PUT /jobs/1
	# PUT /jobs/1.xml
	def update
		@subjects = Subject.all
		@job = Job.find(params[:id])

		if !params[:group_id].nil? && !params[:group_id].empty?
			@org = @job.group

			if params[:job][:status] == 'running' && @org.job_allowance <= @org.jobs.where(:status => 'running').count
				flash[:error] = "You must buy more job packs if you want to run more jobs"
				return redirect_to :back
			end
		end
		
		if @job.update_attributes(params[:job])
			if params[:subjects]
				@job.update_subjects(params[:subjects])
			end

			flash[:success] = "Job was successfully updated."

			if !params[:group_id].nil? && !params[:group_id].empty?
				redirect_to "/manage/#{@job.group_id}"
			else
				redirect_to @job
			end
		else
			format.html { render :action => "edit" }
			format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
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
		@assets= Asset.find(:all, :conditions => ['job_id = ? AND assetType = ?', params[:id], 0])
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
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:org]))
		@jobs = @org.jobs
	end

	def manage_edit
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:org]))
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:id]))
	end

	def manage_new
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:org]))
		@job = Job.new
	end

	def manage_status
		@organizations = User.current.groups.my_permissions('administrator').organization
		raise HTTPStatus::Unauthorized unless @organizations.include?(@org = Group.find(params[:org]))
		@jobs = @org.jobs; raise HTTPStatus::Unauthorized unless @jobs.include?(@job = Job.find(params[:job]))

		if @job.update_attribute(:status, params[:status])
			return render :json => {:status => 'success'}
		else
			return render :json => {:status => 'error'}
		end
	end
end
