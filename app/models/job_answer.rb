class JobAnswer < ActiveRecord::Base
	belongs_to :job_question
	belongs_to :application
end
