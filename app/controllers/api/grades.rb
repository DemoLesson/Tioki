def _grades(params)

	# Get a list of grades
	return Grade.where("`name` LIKE '%#{params[:q]}%'").limit(10).all
end

def _grades_id(id = nil, params)
	Grade.find(id)
end