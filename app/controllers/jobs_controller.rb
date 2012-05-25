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
    
    if params[:location] 
      if params[:subject] || params[:school_type] || params[:grade_level] || params[:calendar] || params[:employment] || params[:special_needs]
        tup = SmartTuple.new(" AND ")

        #tup << ["schools.map_zip = ?", params[:zipcode][:code]] if params[:zipcode][:code].present?

        tup << ["jobs_subjects.subject_id = ?", params[:subject]] if params[:subject].present?

        tup << ["schools.school_type = ?", params[:school_type]] if params[:school_type].present?

        tup << ["schools.grades = ?", params[:grade_level]] if params[:grade_level].present?

        tup << ["schools.calendar = ?", params[:calendar]] if params[:calendar].present?

        tup << ["employment_type = ?", params[:employment]] if params[:employment].present?

        tup << ["special_needs = ?", params[:special_needs]] if params[:special_needs].present?

        if params[:location].present? && params[:location][:city].length > 0
          @schools = School.near(params[:location][:city], params[:radius]).collect(&:id)

          if @schools.size == 0
            #will_paginate does not like nil objects are arrays so just giving it something it will not
            @jobs = Job.unscoped.is_active.near(params[:location][:city], params[:radius]).paginate(:page => params[:page], :order => 'created_at DESC')
          else
            @jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :joins => [:school, :subjects],:conditions => tup.compile, :order => 'created_at DESC')
          end
        else
          @jobs = Job.is_active.paginate(:page => params[:page], :joins => [:school, :subjects], :conditions => tup.compile, :order => 'created_at DESC')
        end
      else
        @schools = School.near(params[:location][:city], params[:radius]).collect(&:id)
        if @schools.size == 0
          #will_paginate does not like nil objects are arrays so just giving it something it will not
          @jobs = Job.unscoped.is_active.near(params[:location][:city], params[:radius]).paginate(:page => params[:page], :order => 'created_at DESC')
        else
          @jobs = Job.where(:school_id => @schools).is_active.paginate(:page => params[:page], :order => 'created_at DESC')
        end
      end

    #if no location is set but other attributes are
    elsif params[:subject] || params[:school_type] || params[:grade_level] || params[:calendar] || params[:employment] || params[:special_needs]
        tup = SmartTuple.new(" AND ")

        #tup << ["schools.map_zip = ?", params[:zipcode][:code]] if params[:zipcode][:code].present?

        tup << ["jobs_subjects.subject_id = ?", params[:subject]] if params[:subject].present?

        tup << ["schools.school_type = ?", params[:school_type]] if params[:school_type].present?

        tup << ["schools.grades = ?", params[:grade_level]] if params[:grade_level].present?

        tup << ["schools.calendar = ?", params[:calendar]] if params[:calendar].present?

        tup << ["employment_type = ?", params[:employment]] if params[:employment].present?

        tup << ["special_needs = ?", params[:special_needs]] if params[:special_needs].present?

        @jobs = Job.is_active.paginate(:page => params[:page], :joins => [:school, :subjects], :conditions => tup.compile, :order => 'created_at DESC')

    elsif params[:search]
      @jobs = Job.is_active.search(params[:search]).paginate(:page => params[:page])

      # @search = Job.search do
      #   fulltext params[:search]
      # end
      #     
      # @jobs = @search.results
    
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
    @job.apply(self.current_user.teacher.id)
    @application = Application.find(:first, :conditions => ['job_id = ? AND teacher_id = ?', @job.id, self.current_user.teacher.id])
    
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
  end

  def tfa_apply
    @job = Job.find(params[:id])
    if (params.has_key?(:job))
      @passcode = params[:job][:passcode]
    else
      @passcode = ''
    end
    
    respond_to do |format|
      if @passcode != nil
        if @passcode == @job.passcode
          @job.apply(self.current_user.teacher.id)
          @teacher = Teacher.find(self.current_user.teacher.id)
          @teacher.tfa = 1
          @teacher.save
          format.html { redirect_to @job, :notice => 'Application successful.' }
        else
          format.html
        end
      else
        format.html
      end
    end

  end

  def job_referral
    @job = Job.find(params[:id])
    
    if self.current_user != nil 
       @teacher_user = self.current_user.teacher.id
    end
    
  end
  
  def job_referral_email
    @job = Job.find(params[:id])
    @referral = params[:referral]
   
   if self.current_user == nil
     @teachername = @referral[:teachername]
   else
     @teacher_user = self.current_user.teacher.id
     @teacher = Teacher.find(@teacher_user)
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
          @job.apply(self.current_user.teacher.id)
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
      if self.current_user.teacher != nil
        @application = Application.find(:first, :conditions => ['job_id = ? AND teacher_id = ?', @job.id, self.current_user.teacher.id])
      end
    end
    
    @school = School.find(@job.school_id)
    @owner = User.find(@school.owned_by)
    
    respond_to do |format|
      if @job.active == true || @job.belongs_to_me(self.current_user) || @job.shared_to_me(self.current_user)
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
    @subjects = Subject.all
    
    respond_to do |format|
      if @job.belongs_to_me(self.current_user) || @job.shared_to_me(self.current_user) 
        format.html
      else
        format.html { redirect_to :root, :notice => 'Unauthorized' }
      end
    end
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    @job = Job.new(params[:job])
    @job.school_id = params[:school_id]
    @job.latitude = @job.school.latitude
    @job.longitude = @job.school.longitude

    respond_to do |format|
      if @job.belongs_to_me(self.current_user) == true  || @job.shared_to_me(self.current_user)
        count=self.current_user.jobcount
        if self.current_user.organization.job_allowance <= count
          redirect_to :root, :notice => 'Your current job allowance is too small to create this job. Please contact support in order to increase it.'
          return
        end
        if @job.save
          if params[:subjects]
            @job.update_subjects(params[:subjects])
          end
          format.html { redirect_to(@job, :notice => 'Job was successfully created.') }
          format.xml  { render :xml => @job, :status => :created, :location => @job }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
        end
      else
        format.html { redirect_to :root, :notice => 'Unauthorized' }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    @job = Job.find(params[:id])
    
    respond_to do |format|
      if @job.update_attributes(params[:job])
        if params[:subjects]
          @job.update_subjects(params[:subjects])
        end
        format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
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
end
