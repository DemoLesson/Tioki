class SkillsController < ApplicationController
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

    # Get the requests skill
    @skill = Skill.find(params[:id])

    # Load teachers that have claimed the above skill
    @teachers = @skill.skill_claims.select('`teachers`.*').joins(:user => :teacher).paginate(:page => params[:page], :per_page => 25)

    # Videos that claim the skill
    @videodb = @skill.videos.paginate(:page => params[:vpage], :per_page => 25)

    # Get a list of my connections
    @my_connections = Connection.mine(:pending => false) unless self.current_user.nil?
    @my_connections = Array.new if self.current_user.nil?
  end
end
