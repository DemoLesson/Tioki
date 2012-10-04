class Technology < ActiveRecord::Base
	has_many :technology_users, :dependent => :destroy
	has_many :users, :through => :technology_users

	has_attached_file :picture,
		:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
		:storage => :s3,
		:content_type => [ 'image/jpeg', 'image/png' ],
		:s3_credentials => Rails.root.to_s+"/config/s3.yml",
		:url  => '/schools/:style/:basename.:extension',
		:path => 'schools/:style/:basename.:extension',
		:bucket => 'DemoLessonS3',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"
end
