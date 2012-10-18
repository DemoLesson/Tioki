class DiscussionsController < ApplicationController
	before_filter :login_required, :except => [:index, :show]
  # GET /discussions
  # GET /discussions.json
  def index
    @discussions = Discussion.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @discussions }
    end
  end

  # GET /discussions/1
  # GET /discussions/1.json
  def show
    @discussion = Discussion.find(params[:id])

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

  # POST /discussions
  # POST /discussions.json
  def create
    @discussion = Discussion.new(params[:discussion])
		@discussion.user = self.current_user


    respond_to do |format|
      if @discussion.save
				if params[:skills]
					params[:skills].each do |skill_id|
						DiscussionTag.create(:discussion => @discussion, :skill_id => skill_id)
					end
				end
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
      if @discussion.update_attributes(params[:discussion])
        format.html { redirect_to @discussion, notice: 'Discussion was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

	def reply_to_discussion
		@discussion = Discussion.find(params[:id])
		@comment = Comment.new
		if request.post?
			@discussion = Discussion.find(params[:id])
			@comment = Comment.build_from(@discussion, self.current_user, params[:comment][:body])
			if @comment.save
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
			comment = Comment.build_from(@discussion, self.current_user, params[:comment][:body])
			if comment.save
				comment.move_to_child_of(@replied_to_comment)
				redirect_to @discussion
			else
				redirect_to :back, :notice => @comment.errors.full_messages.to_sentence
			end
		end
	end

	def followed_discussions
		@discussions = self.current_user.followed_discussions
	end

	def follow_discussion
		@discussion = Discussion.find(params[:id])
		@follower = Follower.new(:discussion => @discussion, :user => self.current_user)
		if @follower.save
			redirect_to :back, :notice => "You are now following this discussion."
		else
			redirect_to :back, :notice => "Unable to follow."
		end
	end

  # DELETE /discussions/1
  # DELETE /discussions/1.json
  def destroy
    @discussion = Discussion.find(params[:id])
    @discussion.destroy

    respond_to do |format|
      format.html { redirect_to discussions_url }
      format.json { head :ok }
    end
  end
end
