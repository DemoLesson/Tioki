class DiscussionsController < ApplicationController
	before_filter :login_required, :except => [:index, :show, :reply_nologin]

  # GET /discussions
  # GET /discussions.json
  def index
    @discussions = Discussion.where(:owner => nil).order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @discussions }
    end
  end

  # GET /discussions/1
  # GET /discussions/1.json
  def show
    @discussion = Discussion.find(params[:id])

    # Unauthorized
    if !@discussion.owner!.nil? && !@discussion.owner!.empty?
    	@owner = @discussion.owner
    	if !@owner.member? && !@owner.permissions['public_discussions']
    		raise HTTPStatus::Unauthorized
    	end
    end

    @comment =Comment.new
		if self.current_user
			@follower = Follower.where("user_id = ? && discussion_id = ?", self.current_user.id, @discussion.id).first
		end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @discussion }
    end
  end

  # GET /discussions/new
  # GET /discussions/new.json
  def new
    @discussion = Discussion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @discussion }
    end
  end

  # GET /discussions/1/edit
  def edit
    @discussion = Discussion.find(params[:id])
  end

	def edit_comment
		@comment = Comment.find(params[:id])
	end

	def update_comment
		@comment = Comment.find(params[:id])

    respond_to do |format|
			#only body can be edited
			if @comment.user_id == self.current_user.id || self.current_user.is_admin

				if @comment.update_attribute(:body, params[:comment][:body])
					format.html { redirect_to @comment.commentable, notice: 'Comment was successfully updated.' }
					format.json { head :ok }
				else
					format.html { render action: "edit_comment" }
					format.json { render json: @comment.errors, status: :unprocessable_entity }
				end

			else
				format.html { redirect_to @discussion }
			end
    end
	end

	# POST /discussions
	# POST /discussions.json
	def create
		@discussion = Discussion.new(params[:discussion])
		@discussion.user = self.current_user

		respond_to do |format|
			if @discussion.save
				if params[:skills]
					params[:skills].uniq.each do |skill_id|
						DiscussionTag.create(:discussion => @discussion, :skill_id => skill_id)
					end
				end

				if @discussion.owner.nil?
					# Tell the whiteboard about this new discussion
					Whiteboard.createActivity(:created_discussion, "{user.link} created a new discussion {tag.link}.", @discussion)
				elsif @discussion.owner.is_a?(Group)
					for user in @discussion.owner.users(:discussion_notifications)
						Notification.create(:notifiable_type => @discussion.tag!, :user_id => user.id)
					end
				end

				# Tell the whiteboard about this new discussion
				Whiteboard.createActivity(:created_discussion, "{user.link} created a new discussion {tag.link}.", @discussion)
				self.log_analytic(:discussion_creation, "New discussion was created.", @discussion, [], :discussions)

				format.html { redirect_to @discussion, notice: 'Discussion was successfully created.' }
				format.json { render json: @discussion, status: :created, location: @discussion }
			else
				format.html { render action: "new" }
				format.json { render json: @discussion.errors, status: :unprocessable_entity }
			end
		end
	end

  # PUT /discussions/1
  # PUT /discussions/1.json
  def update
    @discussion = Discussion.find(params[:id])

    respond_to do |format|
			if @discussion.user_id == self.current_user.id || self.current_user.is_admin

				if @discussion.update_attributes(params[:discussion])

					@discussion.discussion_tags.destroy_all

					if params[:skills]
						params[:skills].uniq.each do |skill_id|
							DiscussionTag.create(:discussion => @discussion, :skill_id => skill_id)
						end
					end

					format.html { redirect_to @discussion, notice: 'Discussion was successfully updated.' }
					format.json { head :ok }
				else
					format.html { render action: "edit" }
					format.json { render json: @discussion.errors, status: :unprocessable_entity }
				end
			else
					format.html { redirect_to @discussion }
			end
    end
  end

	def reply_to_discussion
		@discussion = Discussion.find(params[:id])
		@comment = Comment.new
		if request.post?
			@discussion = Discussion.find(params[:id])
			@comment = Comment.build_from(@discussion, self.current_user.id, params[:comment][:body])

			if @comment.save
				@discussion.following_and_participants.each do |user|
					if user
						if self.current_user.id != user.id
							Notification.create(:notifiable_type => @comment.tag!, :user_id => user.id)
						end
					end
				end
				self.log_analytic(:discussion_comment, "User posted comment in discussion.", @discussion, [], :discussions)
				redirect_to  @discussion
			else
				redirect_to :back, :notice => @comment.errors.full_messages.to_sentence
			end
		end
	end

	def reply_to_comment
		@discussion = Discussion.find(params[:id])
		@replied_to_comment = Comment.find(params[:comment_id])
		@comment = Comment.new
		if request.post?
			@comment = Comment.build_from(@discussion, self.current_user.id, params[:comment][:body])
			if @comment.save
				@comment.move_to_child_of(@replied_to_comment)
				@discussion.following_and_participants.each do |user|
					if user
						if self.current_user.id != user.id
							Notification.create(:notifiable_type => @comment.tag!, :user_id => user.id)
						end
					end
				end
				self.log_analytic(:discussion_comment_reply, "User posted reply to comment in discussion.", @discussion, [], :discussions)
				redirect_to @discussion
			else
				redirect_to :back, :notice => @comment.errors.full_messages.to_sentence
			end
		end
	end

	def reply_nologin
		if self.current_user
			return redirect_to :back, "You are already logined"
		end
		redirect_to "/welcome_wizard?x=step1&discussion_id=#{params[:id]}&body=#{CGI.escape(params[:comment][:body])}"
	end

	def followed_discussions
		@discussions = self.current_user.followed_discussions
	end

	def my_discussions
		@discussions = self.current_user.discussions
	end

	def follow_discussion
		@discussion = Discussion.find(params[:id])
		@follower = Follower.where("user_id = ? && discussion_id = ?", self.current_user.id, params[:id]).first
		if @follower
			return redirect_to :back, :notice => "You are already following this discussion"
		end
		@follower = Follower.new(:discussion => @discussion, :user => self.current_user)
		if @follower.save
			redirect_to :back, :notice => "You are now following this discussion."
			self.log_analytic(:discussion_follow, "User has followed discussion.", @discussion, [], :discussions)
		else
			redirect_to :back, :notice => "Unable to follow."
		end
	end

	def unfollow_discussion
		@follower = Follower.where("user_id = ? && discussion_id = ?", self.current_user.id, params[:id]).first
		if @follower
			@follower.destroy
			redirect_to :back, :notice => "You are no longer following this discussion."
		else
			redirect_to :back, :notice => "You are already not following this discussion."
		end
	end

	def destroy_comment
		#Only remove the the message by
		#marking it as deleted
		@comment = Comment.find(params[:id])
		if self.current_user.is_admin || self.current_user == @comment.user
			@comment.update_attribute(:deleted_at, Time.now)
		end
		redirect_to @comment.root.commentable
	end

	def restore_comment
		@comment = Comment.find(params[:id])

		if self.current_user.is_admin
			@comment.update_attribute(:deleted_at, nil)
		end
		redirect_to @comment.root.commentable
	end

	def destroy_discussion
		#Only remove the the message by
		#marking it as deleted
    @discussion = Discussion.find(params[:id])
		if self.current_user.is_admin || self.current_user == @discussion.user
			@discussion.update_attribute(:deleted_at, Time.now)
		end
    respond_to do |format|
      format.html { redirect_to discussions_url }
      format.json { head :ok }
    end
	end

	def restore_discussion
		@discussion = Discussion.find(params[:id])

		if self.current_user.is_admin
			@discussion.update_attribute(:deleted_at, nil)
		end
		redirect_to @discussion
	end

	def inviting 

		# Load the Discussion
		@discussion = Discussion.find(params[:id])

		# Load in the current users name
		unless self.current_user.nil?
			name = self.current_user.name
		else
			name = "[name]"
		end

		# What is the default message for the email
		@default_message = "I thought you might be interested in joining the \"#{@discussion.title}\" discussion. Check it out on Tioki.\n\n-#{name}"
	end
	
	def discussion_email

		# Load the discussion
		@discussion = Discussion.find(params[:id])

		# Get the post data key
		@referral = params[:referral]

		# Interpret the post data from the form
		@name = @referral[:teachername]
		@emails = @referral[:emails]
		@message = @referral[:message]

		# Swap out any instances of [name] with the name of the sender
		@message = @message.gsub("[name]", @name);

		# Swap out all new lines with line breaks
		@message = @message.gsub("\n", '<br />');

		# Get the current user if applicable
		user = self.current_user unless self.current_user.nil?

		# Send out the email to the list of emails
		UserMailer.discussion_invite_email(@name, @emails, @message, @discussion, user).deliver

		#Log in analytics
		self.log_analytic(:discussion_email_invite, "User email invite to discussion.", @discussion, [], :discussions)

		# Return user back to the home page 
		redirect_to discussion_path(@discussion), :notice => 'Email Sent Successfully'
	end
	
	def invite
		return redirect_to :back unless request.post?
		return redirect_to :back if User.current.nil?

		# Get the discussion
		d = Discussion.find(params[:id])

		subject = "You have been invited to join the \"#{d.title}\" discussion."
		body = <<-BODY
Hi, I was browsing Tioki's discussion board and I thought you might be interested in this discussion.
Come join the conversation. <a href="http://tioki.com/discussions/#{d.id}">Click Here</a>
BODY

		# Send the message
		params[:connection].each do |user|
			Message.send!(user, :subject => subject, :body => body, :tag => "Discussion:#{d.id}")
		end

		self.log_analytic(:discussion_message_invite, "User message invite to discussion.", d, [], :discussions)

		flash[:success] = "Share successfull."
		return redirect_to :back
	end

  # DELETE /discussions/1
  # DELETE /discussions/1.json
  def destroy
    @discussion = Discussion.find(params[:id])

		#Only people who administrate the site can delete the
		#entire discussions and all contents in it
		#
		if self.current_user.is_admin
			@discussion.comment_threads.destroy_all
			@discussion.destroy
		end

    respond_to do |format|
      format.html { redirect_to discussions_url }
      format.json { head :ok }
    end
  end
end
