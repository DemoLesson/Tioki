class Favorite < ActiveRecord::Base
	belongs_to :user

	def model
		_map!(super)
	end
end
