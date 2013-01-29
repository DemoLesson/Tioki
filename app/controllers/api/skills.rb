def _skills(params)

	# Get a list of grades
	return Skill.where("`name` LIKE '%#{params[:q]}%'").limit(10).all
end

def _skills_id(id = nil, params)
	Skill.find(id)
end
