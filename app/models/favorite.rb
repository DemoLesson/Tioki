class Favorite < ActiveRecord::Base
	belongs_to :user

	def model
		mapTag!(super)
	end
end
