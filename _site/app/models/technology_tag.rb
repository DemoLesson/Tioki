class TechnologyTag < ActiveRecord::Base
	belongs_to :technology
	belongs_to :skill
end
