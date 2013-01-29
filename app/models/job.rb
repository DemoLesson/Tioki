class Job < ActiveRecord::Base
	belongs_to :school
	belongs_to :group

	has_and_belongs_to_many :credentials
	has_and_belongs_to_many :subjects
	has_and_belongs_to_many :grades

	has_many :applications
	has_many :winks
	has_many :interviews, :dependent => :destroy
	has_many :assets, :dependent => :destroy
	accepts_nested_attributes_for :assets, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
	reverse_geocoded_by :latitude, :longitude

	scope :is_active, where(:status => 'running')

	#scope :dry_clean_only, joins(:washing_instructions).where('washing_instructions.dry_clean_only = ?', true)

	#Don't show if user account is deactivated

	#default_scope joins(:school => :user).where('users.deleted_at' => nil).readonly(false)

	self.per_page = 15

	def self.search(search)
		where('jobs.title LIKE ? OR jobs.description LIKE ?', "%#{search}%", "%#{search}%")
	end

	def school
		@school = School.find(self.school_id)
		return @school
	end

	def update_subjects(subjects)
		JobsSubjects.delete_all(["job_id = ?", self.id])

		subjects.each do |subject|
			@jobs_subjects = JobsSubjects.new
			@jobs_subjects.job_id = self.id
			@jobs_subjects.subject_id = subject.to_i
			@jobs_subjects.save
		end
	end

	def update_grades(grades)
		GradesJobs.delete_all(["job_id = ?", self.id])

		grades.each do |grade|
			@grades_jobs = GradesJobs.new
			@grades_jobs.job_id = self.id
			@grades_jobs.grade_id = grade.to_i
			@grades_jobs.save
		end
	end

	def zipcode
		return self.school.map_zip
	end

	# @todo deprecate?
	def apply(user_id)
		@application = Application.where('job_id = ? AND user_id = ?', self.id, user_id).first
		if @application == nil
			@application = Application.create!(:job_id => self.id, :user_id => user_id, :status => 1, :viewed => 0)
			UserMailer.teacher_applied(self.school_id, self.id, user_id).deliver
		else
			@application.destroy
		end
	end

	def applicants
		@applicants = Application.where('job_id = ?', self.id).all
		return @applicants
	end

	def new_applicants
		@applicants = Application.where('job_id = ? AND (status = ? || status =?)', self.id, 'Not Reviewed', nil).all
	end

	def belongs_to_me(user)
		if !group_id.nil?
			return group.user_permissions['administrator']
		end

		@school = School.find(self.school)
		belongs = false
		if @school != nil
			if user.id == @school.owned_by
				belongs = true
			end
		end
		return belongs
	end

	#for full admins compare the owned_by of the user to the owned_by of the school
	#for limited admins look up it's row in SharedSchools
	def shared_to_me(user)
		if !group_id.nil?
			return group.user_permissions['administrator']
		end

		@school= School.find(self.school)
		@shared= SharedUsers.where(:user_id => user.id).first
		if @school != nil && @shared != nil
			if user.is_limited == false
				if @shared.owned_by == @school.owned_by
					return true
				else
					return false
				end
			else
				if SharedSchool.where(:user_id => user.id, :school_id => @school.id).first.nil?
					return false
				else
					return true
				end
			end
		else
			return false
		end
	end

	def new_asset_attributes=(asset_attributes)
		assets.build(asset_attributes)
		#asset_attributes.each do |attributes|
		#  assets.build(attributes)
		#end
	end

	def start_date_string
		#can't call to_s with an argument on a nil object
		begin
			start_date.to_s(:jobpicker_time)
		rescue
			start_date
		end
	end

	def deadline_string
		#can't call to_s with an argument on a nil object
		begin
			deadline.to_s(:jobpicker_time)
		rescue
			deadline
		end
	end

	def start_date_string=(start_date_str)
		self.start_date = Time.strptime(start_date_str, "%m/%d/%Y").end_of_day
	rescue ArgumentError
		@state_date_invalid = true
	end

	def deadline_string=(deadline_str)
		self.deadline = Time.strptime(deadline_str, "%m/%d/%Y").end_of_day
	rescue ArgumentError
		@deadline_invalid = true
	end

	def validate
		errors.add(:start_date, "is invalid") if @start_date_invalid
		errors.add(:deadline, "is invalid") if @deadline_invalid
	end

	# @todo can this be cleaned up a bit?
	def cleanup
		@applications = Application.where('job_id = ?', self.id).all
		@applications.each do |application|
			@activity = Activity.where('application_id = ?', application.id).all
			@activity.map(&:destroy)
		end
		@applications.map(&:destroy)
	end

	def save_assets
		assets.each do |asset|
			asset.save
		end
	end

	def link(attrs = {})

		# Parse attrs
		_attrs = []; attrs.each do |k, v|
			# Make sure not a symbol
			k = k.to_s if k.is_a?(Symbol)
			next if k == 'href'
			# Add to attrs array
			_attrs << "#{k}=\"#{v}\""
		end; attrs = _attrs.join(' ')

		# Return the link to the profile
		return "<a href=\"#{url}\" #{attrs}>#{title}</a>".html_safe
	end

	def url
		"/jobs/#{id}"
	end

	def notify_educators
		kvpairs = Kvpair.where("kvpairs.namespace = ? && kvpairs.key = ?", "seeking", "location")

		kvpairs.select!{ |kvpair| kvpair.value == "any" || kvpair.job_within?(self) }

		user_ids = kvpairs.collect(&:map_id)

		subject_ids = self.subjects.collect(&:id)

		grade_ids = self.grades.collect(&:id)

		if subject_ids.count > 0 && grade_ids.count > 0
			users = User.joins(:subjects, :grades).where(:id => user_ids)
		elsif subject_ids.count > 0
			users = User.joins(:subjects).where(:id => user_ids)
		elsif grade_ids.count > 0
			users = User.joins(:grades).where(:id => user_ids)
		else
			users = User.where(:id => user_ids)
		end

		users.each do |user|
			NotificationMailer.job_alert(user, self).deliver
		end

	end
end
