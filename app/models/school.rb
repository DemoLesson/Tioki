class School < ActiveRecord::Base
	reverse_geocoded_by :latitude, :longitude

	has_many :school_administrators, :dependent => :destroy
	has_many :admins, :through => :school_administrators
	
	belongs_to :user, :foreign_key => :owned_by
	attr_protected :owned_by

	has_many :jobs
	self.per_page = 100

	#select schools where users are not deactivated

	default_scope joins(:user).where('users.deleted_at' => nil).readonly(false)
	
	has_attached_file :picture,
		:storage => :fog,
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
		:path => 'schools/:style/:basename.:extension',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"
										
	validates_attachment_content_type :picture, :content_type => [/^image\/(?:jpeg|gif|png)$/, nil], :message => 'Uploading picture failed.'
	validates_attachment_size :picture, :less_than => 2.megabytes,
		:message => 'Picture was too large, try scaling it down.'
	
	def jobs
		@jobs = Job.where('school_id = ? AND active = 1', self.id).all
		return @jobs
	end
	
	def self.job_owner(job_id)
		@job = Job.find(job_id)
		@school = School.find(@job.school_id)
		return @school.owned_by
	end
	
	def belongs_to_me(current_user)
		if self.owned_by == current_user.id 
			return true
		else
			return false
		end
	end

	def shared_to_me(current_user)
		#if full admin all schools are shared
		#if limited only those in SharedSchool
		if(!current_user.is_limited && current_user.is_shared)
			@owner = SharedUsers.where(:user_id => current_user.id).first
			if self.owned_by == @owner.owned_by
				return true
			else
				return false
			end
		else
			if SharedSchool.where(:user_id => current_user.id, :school_id => id).first.nil?
				return false
			else
				return true
			end
		end
	end

  # @todo make faster
	def remove_associated_data
		@jobs = Job.where('school_id = ?', self.id).all
		@jobs.each do |job|
			@applications = Application.where('job_id = ?', job.id).all
			@applications.each do |application|
				@activities = Activity.where('application_id = ?', application.id).all
				@activities.map(&:destroy)
			end
			@applications.map(&:destroy)
			
			@interviews = Interview.where('job_id = ?', job.id).all
			@interviews.each do |interview|
				@activites = Activity.where('interview_id = ?', interview.id).all
			end
			@interviews.map(&:destroy)
		end
		
		@jobs.map(&:destroy)
	end
	
end
