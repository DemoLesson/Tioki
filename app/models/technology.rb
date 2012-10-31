class Technology < ActiveRecord::Base
	has_many :technology_users, :dependent => :destroy
	has_many :users, :through => :technology_users

	has_many :technology_tags, :dependent => :destroy
	has_many :skills, :through => :technology_tags

	# Add Comments
	acts_as_commentable

	# Add support for getting comments
	def getComments
		self.root_comments
	end

	# Create a Comment
	def createComment(body)
		Comment.build_from(self, User.current.id, body)
	end

	def to_param
		"#{id}-#{name.parameterize}"
	end

	has_attached_file :picture,
		:storage => :s3,
		:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
		:content_type => [ 'image/jpeg', 'image/png' ],
		:fog_credentials => {
			:provider => 'AWS',
			:aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
			:aws_secret_access_key  => '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',
			:region => 'us-west-2'
		},
		:fog_public => true,
		:fog_directory => 'tioki',
		:path => 'technologies/:style/:basename.:extension',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"
end
