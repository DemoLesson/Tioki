class InterviewsController < ApplicationController
  before_filter :source_owner

  # Edit the interview in question
  # Author: Kelly Lauren Summer Becker
  # GET /users/:user_id/applications/:application_id/interviews/:interview_id/edit
  # GET /group/:group_id/job/:job_id/applications/:application_id/interviews/:interview_id/edit
  def edit
    @interview = Interview.find(params[:id])

    if @interview.datetime_selected == 4
      @message = <<-END
Dear #{@interview.user.name},

We apologize that the dates did not work out with your schedule. We took the message you sent us to consideration and we have 3 more dates for you to look over. Please have a look over them and let us know if they work for you.

Kind Regards,
#{currentUser.name}
#{@interview.job.group.name}
END
    elsif @interview.datetime_1.nil?
      @message = <<-END
Dear #{@interview.user.name},

After reviewing your profile, video, and documents, we would like to invite you to interview for the #{@interview.job.title} position available at #{@interview.job.group.name}. Please confirm if any of these dates and times work for you. We look forward to meeting with you!

Kind Regards,
#{currentUser.name}
#{@interview.job.group.name}
END
    else
      @message = String.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  # Update the interview
  # Author: Kelly Lauren Summer Becker
  # POST /users/:user_id/applications/:application_id/interviews/:interview_id
  # POST /group/:group_id/job/:job_id/applications/:application_id/interviews/:interview_id
  def update
    @interview = Interview.find(params[:id])

    # If the message is empty go ahead and remove it from the parameters
    params[:interview].delete(:message) if params[:interview][:message].strip.empty?

    if @source.is_a?(User)

      # Send a message to the administrator regarding the interview
      if !params[:interview][:message].nil?
        @source.job.group.users(:administrator).each do |to|
          Message.send!(to, :subject => "Re: Interview with #{@interview.user.name} for #{@interview.job.title} position",
            :body => params[:interview][:message], :tag => @interview.tag!)
        end
      end
    end

    # Go ahread an parse the dates
    if @source.is_a?(Job)
      params[:interview][:datetime_1] = Chronic.parse(params[:interview][:datetime_1])
      params[:interview][:datetime_2] = Chronic.parse(params[:interview][:datetime_2])
      params[:interview][:datetime_3] = Chronic.parse(params[:interview][:datetime_3])
      params[:interview][:datetime_selected] = 0 if @interview.datetime_selected == 4

      # Send a message to the application regarding the interview
      if !params[:interview][:message].nil?
        Message.send!(@interview.user, :subject => "Re: Interview with #{@interview.job.group.name} for #{@interview.job.title} position",
          :body => params[:interview][:message], :tag => @interview.tag!)
      end
    else
      params[:interview].delete_if{|k,v|[:datetime_1, :datetime_2, :datetime_3, :message].include?(k)}
    end

    respond_to do |format|
      if @interview.update_attributes(params[:interview])

        # Get the redirect url based on the source of the submission
        goto = [@source, :applications]
        goto = goto.unshift(@source.group) if @source.is_a?(Job)

        format.html { redirect_to goto, notice: 'Interview details have been updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
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
