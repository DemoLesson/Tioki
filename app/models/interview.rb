class Interview < ActiveRecord::Base
	attr_accessible :location, :message, :number, :interview_type,
					:datetime_1, :datetime_2, :datetime_3, :datetime_selected,
					:job_id, :user_id, :application_id,
					:job, :user, :application

	# Relations
	belongs_to :application
	belongs_to :user
	belongs_to :job

	# Interview Date
	def intDate
		case datetime_selected
			when 1
				return datetime_1.to_s(:datetime)
			when 2
				return datetime_2.to_s(:datetime)
			when 3
				return datetime_3.to_s(:datetime)
			when 4
				return 'Reschedule Requested'
			else
				return 'Unscheduled'
		end
	end

	# Stub
	def link
	end

	# Stub
	def url
	end

end
