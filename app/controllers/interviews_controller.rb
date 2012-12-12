class InterviewsController < ApplicationController
  before_filter :login_required
  before_filter :source_owner
  
  # GET /interviews
  # GET /interviews.json
  def index
    @interviews = Interview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interviews }
    end
  end
  
  # GET /my_interviews
  # GET /my_interviews.json
  
  def my_interviews
    @interviews = Interview.find(:all, :conditions => ['user_id = ?', self.current_user.id])
    
    respond_to do |format|
      format.html # my_interviews.html.erb
      format.json { render json: @interviews }
    end
  end
  
  # POST /interviews/respond
  # POST /interviews/respond.json
  
  def respond
    @interview = Interview.find(params[:id])
    @job = Job.find(@interview.job_id)

    respond_to do |format|
      if self.current_user == nil || @interview.user_id != self.current_user.id
        render :nothing => true, :status => "Forbidden" 
      else
        UserMailer.interview_scheduled(self.current_user.id, @job.id).deliver
        format.html
        format.json
      end
    end
  end

  # GET /interviews/1
  # GET /interviews/1.json
  def show
    @interview = Interview.find(params[:id])

    respond_to do |format|
      if self.current_user != nil
        if @interview.user_id != self.current_user.id
          render :nothing => true, :status => "Forbidden"
        else
          format.html # show.html.erb
          format.json { render json: @interview }
        end
      elsif self.current_user.school != nil
        if Job.find(@interview.job_id).school_id != self.current_user.school.id
          render :nothing => true, :status => "Forbidden"
        else
          format.html # show.html.erb
          format.json { render json: @interview }
        end
      end
    end
  end

  # Edit the interview in question
  # Author: Kelly Lauren Summer Becker
  # GET /users/:user_id/applications/:application_id/interviews/:interview_id
  # GET /group/:group_id/job/:job_id/applications/:application_id/interviews/:interview_id
  def edit
    @interview = Interview.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  # POST /interviews/new
  # POST /interviews/new.json
  def new
    session[:return_to] ||= request.referer
    @interview = Interview.new
    @job = Job.find_by_id(params[:job_id])
    @user = User.find(params[:user_id])
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  # POST /interviews
  # POST /interviews.json
  def create
    @interview = Interview.new(params[:interview])
    if params[:minute]==""
      params[:minute]="00"
    end
    if params[:minute1]==""
      params[:minute1]="00"
    end
    if params[:minute2]==""
      params[:minute2]="00"
    end
    date1 = params[:date]+ " " + params[:hour] + ":" +params[:minute] + " " +params[:ampm]
    date2 = params[:alternateDate]+ " " + params[:hour1] + ":" +params[:minute1] + " " +params[:ampm1]
    date3 = params[:alternateDate2]+ " " + params[:hour2] + ":" +params[:minute2] + " " +params[:ampm2]
    begin
      date=Time.strptime(date1, "%m/%d/%Y %I:%M %p")
    rescue
      redirect_to :back, :notice => "There was something wrong with with your first date"
      return
    end
    begin
      date_alternate=Time.strptime(date2, "%m/%d/%Y %I:%M %p")
    rescue
      date_alternate=date
    end
    begin
      date_alternate_second= Time.strptime(date3, "%m/%d/%Y %I:%M %p")
    rescue
      date_alternate_second=date
    end


    @interview.date = date
    @interview.date_alternate = date_alternate
    @interview.date_alternate_second = date_alternate_second
    @interview.user_id = params[:interview][:user_id]
    @interview.job_id = params[:interview][:job_id]
    
    respond_to do |format|
      if @interview.save
        UserMailer.interview_notification(@interview.user_id, @interview.job_id).deliver
        
        format.html { redirect_to session[:return_to], notice: 'Interview request has been sent.' }
        format.json { render json: @interview, status: :created, location: @interview }
      else
        format.html { render action: "new" }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interviews/1
  # PUT /interviews/1.json
  def update
    @interview = Interview.find(params[:id])

    # Go ahread an parse the dates
    params[:interview][:date] = Chronic.parse(params[:interview][:date])
    params[:interview][:date_alternate] = Chronic.parse(params[:interview][:date_alternate])
    params[:interview][:date_alternate_second] = Chronic.parse(params[:interview][:date_alternate_second])

    respond_to do |format|
      if @interview.update_attributes(params[:interview])
        format.html { redirect_to [@source.group, @source, @interview.application], notice: 'Interview details have been updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interviews/1
  # DELETE /interviews/1.json
  def destroy
    @interview = Interview.find(params[:id])
    @interview.deactivify
    @interview.destroy

    if @interview.application != nil
      @interview.application.reject
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :ok }
    end
  end

  protected
  
    def source_owner
      # Get the proper source
      @source = User.find(params[:user_id]) unless params[:user_id].nil?
      @source = Job.find(params[:job_id]) unless params[:job_id].nil?

      # Check permissions to see if the owner also has application
      raise SecurityTransgression if !@source.applications.include?(Application.find(params[:application_id]))

      # Check to make sure the if the user is accessing that the user is the current one
      raise SecurityTransgression if @source != User.current if @source.is_a?(User)

      # Check permissions on the job side
      if @source.is_a?(Job)
        #raise SecurityTransgression if @source.group != Group.find(params[:group_id])
        #raise SecurityTransgression if !@source.group.user_permissions.administrator
      end
    end
end
