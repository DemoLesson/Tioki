class WhiteboardsHidden < ActiveRecord::Base
	has_many :whiteboard
	has_many :user, :as => :whiteboards_hidden
end
