class Application < ActiveRecord::Base
	has_many :assets, :dependent => :destroy
	belongs_to :job
	belongs_to :user

	belongs_to :video
	has_many :interviews, :dependent => :destroy

	scope :is_active, where(:status => 1)
	scope :is_submitted, where(:submitted => 1)
	scope :not_rejected, where("status is null || status != 'Deny Application'")

	def self.mine(args = {})

		# Set the user to lookup
		a = User.current.id if args[:user].nil?
		a = args[:user] unless args[:user].nil?

		# Get all my applications
		tmp = self.where('`user_id` = ?', a)

		# Filter down
		tmp = tmp.where('`viewed` = ?', args[:viewed]) unless args[:viewed].nil?
		tmp = tmp.where('`status` = ?', args[:status]) unless args[:status].nil?
		tmp = tmp.where('`status` != ?', args[:status!]) unless args[:status!].nil?

		return tmp
	end

	def self.find_by_user_job(user_id, job_id)
		Application.where('user_id = ? AND job_id = ?', self.user_id, self.job_id).first
	end

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
