def _subjects(params)

	# Get a list of subjects
	return Subject.where("`name` LIKE '%#{params[:q]}%'").limit(10).all
end

def _subjects_id(id = nil, params)
	Subject.find(id)
end