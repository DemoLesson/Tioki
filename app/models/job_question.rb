class JobQuestion < ActiveRecord::Base
	has_one :job_answers, :dependent => :destroy
end
