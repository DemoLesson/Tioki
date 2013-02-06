class JobAnswer < ActiveRecord::Base
	has_one :job_question
end
