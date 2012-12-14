class EventsEventformats < ActiveRecord::Base
	has_many :event
	has_many :eventformat
end
