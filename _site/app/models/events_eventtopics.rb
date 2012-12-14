class EventsEventtopics < ActiveRecord::Base
	has_many :event
	has_many :eventtopic
end
