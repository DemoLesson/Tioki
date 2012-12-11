class ApplicationsController < ApplicationController
	before_filter :login_required
	before_filter :source_owner

	# GET /applications
	# GET /applications.xml
	def index
		@applications = @source.applications

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :json => @applications }
		end

		return true
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

	# Deprecate
	def teacher_applications
		@featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')
		@interviews = Interview.paginate :conditions => ['user_id = ?', self.current_user.id], :order => 'created_at DESC', :page => params[:interview_page], :per_page => 5
		@applications = Application.paginate :conditions => ['user_id = ?', self.current_user.id], :order => 'created_at DESC', :page => params[:application_page], :per_page => 5
		@pendingcount = Connection.find(:all, :conditions => ['user_id = ? AND pending = true', self.current_user.id]).count  
	end

	def appattachments
		@application = Application.find(params[:id])
		@user = self.current_user
	end

	protected

		def source_owner
			@source = User.find(params[:user_id]) unless params[:user_id].nil?
			@source = Job.find(params[:job_id]) unless params[:job_id].nil?
		end
end
