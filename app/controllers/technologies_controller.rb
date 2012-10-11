class TechnologiesController < ApplicationController
	before_filter :authenticate, :except => [ :index, :show, :add_technology, :remove_technology]

  # GET /technologies
  # GET /technologies.json
  def index
    @technologies = Technology.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technologies }
    end
  end

  def technology_list
    @technologies = Technology.all
    @stats = []
    @stats.push({:name => 'Technologies', :value => Technology.count})
    @stats.push({:name => 'Teachers Using', :value => TechnologyUser.count})
  end

  # GET /technologies/1
  # GET /technologies/1.json
  def show
    @technology = Technology.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/new
  # GET /technologies/new.json
  def new
    @technology = Technology.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/1/edit
  def edit
    @technology = Technology.find(params[:id])
  end

  # POST /technologies
  # POST /technologies.json
  def create
    @technology = Technology.new(params[:technology])

    respond_to do |format|
      if @technology.save
        format.html { redirect_to "/technologylist", notice: 'Technology was successfully created.' }
        format.json { render json: @technology, status: :created, location: @technology }
      else
        format.html { render action: "new" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technologies/1
  # PUT /technologies/1.json
  def update
    @technology = Technology.find(params[:id])

    respond_to do |format|
      if @technology.update_attributes(params[:technology])
        format.html { redirect_to "/technologylist", notice: 'Technology was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1
  # DELETE /technologies/1.json
  def destroy
    @technology = Technology.find(params[:id])
    @technology.destroy

    respond_to do |format|
      format.html { redirect_to "/technologylist", notice: 'Technology was successfully removed.' }
      format.json { head :ok }
    end
  end

  def add_technology
    @technology_user = TechnologyUser.find(:first, :conditions => ['user_id = ? && technology_id = ?', self.current_user.id, params[:id]])
		if @technology_user
			redirect_to :back, :notice => "You have already added this technology."
		else
			tech = TechnologyUser.create(:user => self.current_user, :technology_id => params[:id])
      self.log_analytic(:user_added_technology, "A user added a technology tag to their profile", tech)
			redirect_to :back, :notice => "Technology was successfully added."
		end
  end

  def remove_technology
    @technology_user = TechnologyUser.find(:first, :conditions => ['user_id = ? && technology_id = ?', self.current_user.id, params[:id]])
    self.log_analytic(:user_removed_technology, "A user removed a technology tag from their profile", @technology_user)
		@technology_user.destroy
    respond_to do |format|
      format.html { redirect_to technologies_url, notice: 'Technology was successfully removed.' }
    end
  end

	def change_technology_picture
    @technology = Technology.find(params[:id])
	end

	def edit_technology_tags
		@technology = Technology.find(params[:id])

		# Detect post variables
		if request.post?

			# Load the teach and update
			@teacher = self.current_user.teacher
			@technology.skills.delete_all

			# Install the skills
			skills = Skill.where(:id => params[:skills].split(','))
			skills.each do |skill|
				TechnologyTag.create(:technology => @technology, :skill_id => skill.id)
			end
			redirect_to "/technologylist", :notice => "Skills saved."
		end
		# Get a list of existing skills
		@existing_skills = technology_path(@technology) + '/skills'
	end

	def skills
		@technology = Technology.find(params[:id])
		@skills = @technology.skills

		@skills.collect! do |v|
			data = v.serializable_hash
			data["skill_group"] = v.skill_group.name.to_sym
			v = data
		end

		render :json => @skills
	end

	def techsuggestion
		@technology_suggestion = TechnologySuggestion.new
		 id = self.current_user.id
	end

	def sendtechsuggestion
		TechnologySuggestion.create(params[:technology_suggestion])
		redirect_to :back, :notice => "Thank you for your suggestion."
	end
	
  private
  def authenticate
    return true if !self.current_user.nil? && self.current_user.is_admin

    # If auth fail
    render :text => "Access Denied"
    return 401

    # Block old HTTP Auth
    #authenticate_or_request_with_http_basic do |id, password| 
    #  id == USER_ID && password == PASSWORD
    #end
  end
  
end
