class Videos_Skills < ActiveRecord::Base
	has_many :videos
	has_many :skills
end
