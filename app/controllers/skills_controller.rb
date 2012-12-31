class SkillsController < ApplicationController

	def skills_url; '/me/profile/edit/skills'; end

	def show
	    # Get the requests skill
	    @skill = Skill.find(params[:id])

	    # Load teachers that have claimed the above skill
			@users = User.joins(:skill_claims).
				where("skill_claims.skill_id = ?", @skill.id).
				paginate(:page => params[:page], :per_page => 25, :order => "users.connections_count DESC")

	    # Videos that claim the skill
	    @videodb = @skill.videos.paginate(:page => params[:vpage], :per_page => 25)
	    
	    #Technologies that claim the skill
	    @technologies = @skill.technologies

	    # Get a list of my connections
	    @my_connections = Connection.mine(:pending => false) unless currentUser.new_record?
	    @my_connections = Array.new if currentUser.new_record?

	    # Get a list of events
	    @events = Event.where("`events`.`end_time` >= CURDATE() && `skills`.`id` = ?", @skill.id).
				order('`events`.`start_time` ASC').joins(:skills).limit(5)

	    # Get the associated discussions
	    @discussions = Discussion.joins(:skills).where("`skills`.`id` = ?", @skill.id)

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @skill }
		end
	end

	def skillpage
		skill = Skill.find(params[:topic])
		redirect_to skill
	end

  	def create

  		# Current user
  		@user = User.current

		# Delete all skills attached to the user
		@user.skills.delete_all
		
		# Parse the skill array
		skills = Skill.where(:id => params[:skills].split(','))

		# This adds the skills to the user so :D no need to do anything else
		skills.each do |skill|
			SkillClaim.create(:user_id => @user.id, :skill_id => skill.id, :skill_group_id => skill.skill_group_id)
		end

		redirect_to :skills
  	end
  
    def my_skills
		@user = User.find_by_slug(params[:slug]) unless params[:slug].nil?
		@user = User.current if params[:slug].nil?
		@skills = @user.skills

		@skills.collect! do |v|
			data = v.serializable_hash
			data["skill_group"] = v.skill_group.name.to_sym
			v = data
		end

		render :json => @skills
	end
	
	def index

		# Existing skills path
		@existing_skills = skills_path + '/my_skills'
		
		respond_to do |format|
			format.html { render :index }
			format.json do

				# If the tokenizer is asking
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

				render :json => @skills 
			end
		end
	end
end
