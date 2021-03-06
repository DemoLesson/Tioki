class ApplicationsController < ApplicationController
	before_filter :login_required
	before_filter :source_owner

	# Application and Interviews listing
	# Author: Kelly Lauren Summer Becker
	# GET /user/:user_id/applications
	# GET /groups/:group_id/jobs/:job_id/applications
	def index
		if @source.is_a?(User)
			@applications = @source.applications
		else
			@applications = @source.applications.is_submitted
		end
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
		if !params[:application].nil? && params[:application][:status] == 'Request an Interview' && @application.interviews.empty?
			redirect = new_group_job_application_interview_path(@source.group, @source, @application)
		end

		# Handle rejection letter
		if !params[:application].nil? && params[:application][:status] == 'Deny Application'
			redirect = [:message, @source.group, @source, @application]
		end

		if not params[:message].nil?
			Message.send!(@application.user,
				:from => currentUser,
				:subject => params[:subject],
				:body => params[:message],
				:tag => @application.tag!)

			return redirect_to [@source.group, @source, :applications], :notice => 'Rejection notice successfully sent.'
		end

		respond_to do |format|

			# Go ahead and try to save
			if @application.update_attributes(params[:application])

				# Respond with either HTML or JSON
				format.html {

					# If we have an alternate location to redirect to
					return redirect_to(redirect) if not redirect.nil?

					# Otherwise redirect to to the groups applications
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

	# Send the applicant a message
	# Author: Kelly Lauren Summer Becker
	# POST /groups/:group_id/jobs/:job_id/applications/:id/message
	def message
		@application = Application.find(params[:id])
	end

	def show
		@application = Application.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :json => @application }
		end
	end

	def attachments
		@application = Application.find(params[:id])
		@profileassets = @application.assets
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

	def destroy
		@application = Application.find(params[:id])

		# Only allow destruction of unsubmitted applications
		@application.destroy if @application.submitted == 0
		redirect_to :back
	end

	# Deprecate
	def teacher_applications
		@featuredjobs = Job.where('active = ?', true).order('created_at DESC').all
		# @todo review is this still accuracte?
		@interviews = Interview.paginate :conditions => ['user_id = ?', self.current_user.id], :order => 'created_at DESC', :page => params[:interview_page], :per_page => 5
		@applications = Application.paginate :conditions => ['user_id = ?', self.current_user.id], :order => 'created_at DESC', :page => params[:application_page], :per_page => 5
		@pendingcount = Connection.where('user_id = ? AND pending = true', self.current_user.id).count
	end

	def appattachments
		@application = Application.find(params[:id])
	end

	def reviewed_applicants
		@applications = @source.applications.is_submitted
	end

	def interviews
		@round = params[:round] ? params[:round].to_i : 1

		@interviews = @source.interviews.where("round = ?", @round).order("created_at DESC")
	end

	def offered
		@applications = @source.applications.is_submitted
	end

	def accepted
		@applications = @source.applications.is_submitted
	end

	def hired
		@applications = @source.applications.is_submitted
	end

	def declined
		@applications = @source.applications.is_submitted
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
