class Application < ActiveRecord::Base
	has_many :assets, :as => :owner,:dependent => :destroy
	belongs_to :job
	belongs_to :user

	belongs_to :video
	has_many :interviews, :dependent => :destroy
	has_many :job_answers, :dependent => :destroy

	scope :is_active, where(:status => 1)
	scope :is_submitted, where(:submitted => 1)
	scope :not_rejected, where("status is null || status != 'Deny Application'")

	scope :not_reviewed, where(:status => 'Not Reviewed')
	scope :reviewed, where(:status => ['Profile Reviewed', 'Request An Interview'])
	scope :has_interviews, joins(:interviews)
	scope :offered, where(:status => 'Offer Given')
	scope :accepted, where(:status => 'Offer Accepted')
	scope :hired, where(:status => 'Applicant Hired')
	scope :declined, where(:status => 'Deny Application')


	def reject
		self.status = 0
		self.save
	end

	def booked
		@interviews = Interview.where('user_id = ? AND job_id = ?', self.user_id, self.job_id).first
	end

	def belongs_to_me(user)
		job=Job.find_by_id(self.job_id)
		if job != nil
			if job.belongs_to_me(user) || job.shared_to_me(user)
				return true
			else
				return false
			end
		else
			return false
		end
	end

	# Stub
	def link
	end

	# Stub
	def url
	end
end
