class Eventformat < ActiveRecord::Base
	has_and_belongs_to_many :events, :join_table => 'events_eventformats'
	has_many :events_eventformats
end
