def _users(block = nil)
	__rank
	User.limit(20).all
end

def _users_id(id = nil, block = nil)
	__rank
	User.find(id)
end