class Analytic < ActiveRecord::Base
	belongs_to :user

	def map_tag
		mapTag!(self.tag)
	end
end
