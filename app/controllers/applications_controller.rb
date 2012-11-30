class ApplicationsController < ApplicationController
  before_filter :login_required
  
  # GET /applications
  # GET /applications.xml
  def index
    @job = Job.find(params[:id])
    @applications = Application.find(:all, :conditions => ['job_id = ? AND status = ?', @job.id, 1])
    @applications.each do |application|
      application.viewed = 1
      application.save
    end
    
    @school = School.find(@job.school_id)
    @owner = User.find(@school.owned_by)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :json => @applications }
    end
  end

  # GET /applications/1
  # GET /applications/1.xmlst
  def show
    @application = Application.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :json => @application }
    end
  end

  # Revise
  def attachments
    @application= Application.find(params[:id])
    @profileassets= Asset.find(:all, :conditions => ['user_id = ? AND assetType = ?', @application.user_id, 0])
    respond_to do |format|
      format.html # attachments.html.erb
    end
  end
  
  def reject
    @application = Application.find(params[:id])
    @user_id = @application.user_id
    @job_id = @application.job_id
    @application.reject
    
    respond_to do |format|
      UserMailer.rejection_notification(@user_id, @job_id, self.current_user.name).deliver
      format.html { redirect_to :my_jobs }
    end
  end  
  
    def teacher_applications
        @featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')
        @interviews = Interview.paginate :conditions => ['teacher_id = ?', self.current_user.teacher.id], :order => 'created_at DESC', :page => params[:interview_page], :per_page => 5
        @applications = Application.paginate :conditions => ['teacher_id = ?', self.current_user.teacher.id], :order => 'created_at DESC', :page => params[:application_page], :per_page => 5
        @pendingcount = Connection.find(:all, :conditions => ['user_id = ? AND pending = true', self.current_user.id]).count  
    end
end
