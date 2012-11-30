class SkillsController < ApplicationController

	def show
    # Get the requests skill
    @skill = Skill.find(params[:id])

    # Load teachers that have claimed the above skill
		@users = User.joins(:skill_claims).where("skill_claims.skill_id = ?", @skill.id).paginate(:page => params[:page], :per_page => 25)

    # Videos that claim the skill
    @videodb = @skill.videos.paginate(:page => params[:vpage], :per_page => 25)
    
    #Technologies that claim the skill
    @technologies = @skill.technologies

    # Get a list of my connections
    @my_connections = Connection.mine(:pending => false) unless self.current_user.nil?
    @my_connections = Array.new if self.current_user.nil?

    # Get a list of events
    @events = Event.where("`events`.`end_time` >= CURDATE() && `skills`.`id` = ?", @skill.id).order('`events`.`start_time` ASC').joins(:skills).limit(5)

    # Get the associated discussions
    @discussions = Discussion.joins(:skills).where("`skills`.`id` = ?", @skill.id)

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @skill }
		end
	end

  def get
    if params[:tokenizer].nil?
      if params[:q].nil?
        @skills = Skill.all(:limit => 10)
      else
        @skills = Skill.where("name like ?", "%#{params[:q]}%").limit(10)
      end
    else
      skills = Skill.all

      @skills = Hash.new
      skills.each do |v|

        # Hashify
        data = v.serializable_hash
        skillgroup = v.skill_group.name.to_sym
        data["skill_group"] = skillgroup
        v = data

        # Put on the array
        @skills[skillgroup] = Array.new if @skills[skillgroup].nil?
        @skills[skillgroup] << v
      end
    end

    respond_to do |format|
      format.json { render :json => @skills }
    end
  end

  def teacherskills
		#Depreciated
		#There are still links to the teacherskill page so just redirect to
		#to the new show page
		@skill = Skill.find(params[:id])
		redirect_to @skill
  end
  
  def skillpage
    #Redirecting users to skills pages
		@skill = Skill.find(params[:topic])
    redirect_to @skill
  end
  
    def skills
		@teacher = User.find(params[:id])
		@skills = @teacher.skills

		@skills.collect! do |v|
			data = v.serializable_hash
			data["skill_group"] = v.skill_group.name.to_sym
			v = data
		end

		render :json => @skills
	end
	
	def edit_skills
		
		# Detect post variables
		if request.post?

			# Load the teach and update
			@teacher = self.current_user
			@teacher.user.skills.delete_all
			
			# Install the skills
			skills = Skill.where(:id => params[:skills].split(','))
			skills.each do |skill|
				SkillClaim.create(:user_id => @teacher.id, :skill_id => skill.id, :skill_group_id => skill.skill_group_id)
			end

			#dump skills
			@teacher.skills = skills
			
			# Attempt to save the user
			if @teacher.save

				# Notice and redirect
				session[:wizard] = true
				flash[:notice] = "Skills Updated"
			else

				# If the user save failed then notice and redirect
				flash[:notice] = @teacher.errors.full_messages.to_sentence
			end
		end

		# Get a list of existing skills
		@existing_skills = user_path(self.current_user) + '/skills'
	end
end
