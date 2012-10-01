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
    @skill = Skill.find(params[:id])
    @teachers = Teacher.joins(:user => :skills).paginate(:page => params[:page], :per_page => 25, :conditions => ['teachers.user_id = skill_claims.user_id and skill_claims.skill_id = ?', params[:id]])
	if self.current_user
		@my_connections = Connection.find_for_user(self.current_user.id).collect(&:user_id)
	else
		@my_connections = []
	end
  end
end
