class ApplicationsController < ApplicationController
	before_filter :login_required
	before_filter :source_owner

	# Application and Interviews listing
	# Author: Kelly Lauren Summer Becker
	# GET /user/:user_id/applications
	# GET /groups/:group_id/jobs/:job_id/applications
	def index
		@applications = @source.applications.is_submitted
		@interviews = @source.interviews

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :json => @applications }
		end

		return true
	end

	# Update the application status and details
	# Author: Kelly Lauren Summer Becker
	# POST /groups/:group_id/jobs/:job_id/applications/:id
	def update
		@application = Application.find(params[:id])

		# If an interview was requested go ahead and create the interview
		if params[:application][:status] == 'Request an Interview' && @application.interview.nil?
			interview = Interview.create(
				:application => @application,
				:user => @application.user,
				:job => @application.job)
		end

		respond_to do |format|

			# Go ahead and try to save
			if @application.update_attributes(params[:application])

				# Respond with either HTML or JSON
				format.html {

					# If an interview was created take the person to the edit interview page
					return redirect_to [:edit, @source.group, @source, @application, interview] if interview.is_a?(Interview)
					redirect_to [@source.group, @source, :applications], :notice => 'Application was successfully updated.'
				}
				format.json { head :no_content }
			else
				# Delete the interview if it failed to save
				interview.destroy if interview.is_a?(Interview)

				# Respond with either HTML or JSON
				format.html { render action: "edit" }
				format.json { render json: @application.errors, status: :unprocessable_entity }
			end
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
		@application = Application.find(params[:id])
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

			# Check to make sure the if the user is accessing that the user is the current one
      		raise SecurityTransgression if @source != User.current if @source.is_a?(User)

			# Check permissions on the job side
			if @source.is_a?(Job)
				#raise SecurityTransgression if @source.group != Group.find(params[:group_id])
				#raise SecurityTransgression if !@source.group.user_permissions.administrator
			end
		end
end
