class Technology < ActiveRecord::Base
	has_many :technology_users, :dependent => :destroy
	has_many :users, :through => :technology_users

	has_many :technology_tags, :dependent => :destroy
	has_many :skills, :through => :technology_tags

	has_attached_file :picture,
		:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
		:storage => :fog,
		:content_type => [ 'image/jpeg', 'image/png' ],
		:fog_credentials => {
			:provider => 'AWS',
			:aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
			:aws_secret_access_key => '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'
		},
		:fog_public => true,
		:fog_directory => 'DemoLessonS3',
		:url  => '/technologies/:style/:basename.:extension',
		:path => 'technologies/:style/:basename.:extension',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"
end
