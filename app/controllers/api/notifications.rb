def _notifications(block = nil)
	__rank
	format = Notification.limit(10).all
	format
end

def _notifications_id(id = nil, block = nil)
	__rank
	note = Notification.find(id)
	return note unless request.post?

	# Mark notification as read
	note.update_attribute(:read, true)
	return note
end