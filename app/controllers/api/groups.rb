def _groups(params)
	__rank

	# Get a list of groups
	unless request.post?
		return Group.limit(20).all

	# Create a new group
	else
		group = Group.new(params)
		return group if group.save
	end
end

def _groups_id(id = nil, params)
	__rank
	Group.find(id)
end