class Attachment

	# Polymorphic connection to owner
	belongs_to :owner, :polymorphic => true

	# Connect to a video for whiteboard purposes
	belongs_to :video

	# Uploaded file support
	has_attached_file :file

	# Store any additional information
	serialize :data
end