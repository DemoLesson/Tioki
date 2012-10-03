class Videos_Favorites < ActiveRecord::Base
	has_many :videos
	has_many :users
end
