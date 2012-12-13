module EventsHelper
	# Format the date for the event method
	def date2format(event, row = "start_time", format = "%m/%d/%Y")
		event[row].localtime.to_datetime.strftime(format) unless event[row] == nil
	end

	def event_hours(event, start_time = "start_time", end_time = "end_time", same_day = "%l:%M%P", diff_day = "%m/%d/%Y %l:%M%P")
		return "No dates (This is a big error)" if event[start_time] == nil || event[end_time] == nil

		hours = ''
		if event[start_time].to_datetime.strftime("%m/%d/%Y") == event[end_time].to_datetime.strftime("%m/%d/%Y")
			hours << event[start_time].localtime.to_datetime.strftime(same_day)
			hours << " to "
			hours << event[end_time].localtime.to_datetime.strftime(same_day)
			hours << " on " + event[start_time].localtime.to_datetime.strftime("%m/%d/%Y")
		else
			hours << event[start_time].localtime.to_datetime.strftime(diff_day)
			hours << " to "
			hours << event[end_time].localtime.to_datetime.strftime(diff_day)
		end
	end

	def event_dates(event)
		return "No dates!" if event.start_time == nil || event.end_time == nil

		_start = event.start_time
		_end = event.end_time

		hours = ''
		if _start.strftime("%m/%d/%Y") == _end.strftime("%m/%d/%Y")
			day = _start.strftime('%-d').to_i.ordinalize
			hours << "<strong>Date</strong><br />"
			hours << _start.strftime("%A %B #{day}, %Y<br />")
			hours << "From "
			hours << _start.strftime("%l:%m %P")
			hours << " - "
			hours << _end.strftime("%l:%m %P %Z")
		else
			_start_day = _start.strftime('%-d').to_i.ordinalize
			_end_day = _start.strftime('%-d').to_i.ordinalize
			hours << "<strong>Start Date</strong><br />"
			hours << _start.strftime("%A %B #{_start_day}, %Y<br />")
			hours << _start.strftime("%l:%m %P %Z")
			hours << "<br /><br /><strong>End Date</strong><br />"
			hours << _end.strftime("%A %B #{_end_day}, %Y<br />")
			hours << _end.strftime("%l:%m %P %Z")
		end

		return hours.html_safe
	end

	def rsvp_status(event)
		!(!self.current_user.nil? && self.current_user.rsvp.index(event) == nil)
	end

	def location(type = :physical, event)
		if type == :physical
			location = ''
			location << "<strong>#{event.loc_name}</strong><br />" unless event.loc_name.empty?
			location << "#{event.loc_address1}<br />" unless event.loc_address1.empty?
			location << "#{event.loc_city}, " unless event.loc_city.empty?
			location << "#{event.loc_state}<br />" unless event.loc_state.empty?
			location << "#{event.loc_zip}<br />" unless event.loc_zip.empty?
		elsif type == :virtual
			location = ''
			location << "Phone Call In Number: #{event.virtual_phone}<br />" unless event.virtual_phone.empty?
			location << "Phone Access Code: #{event.virtual_phone_access}<br />" unless event.virtual_phone_access.empty?
			location << "Website Event: <a href=\"#{event.virtual_web_link}\" target=\"_blank\">#{event.virtual_web_link}</a><br />" unless event.virtual_web_link.empty?
			location << "Website Access Code: #{event.virtual_web_access}<br />" unless event.virtual_web_access.empty?
			location << "TV Station: #{event.virtual_tv_station}<br />" unless event.virtual_tv_station.empty?
		end
		return ActionController::Base.helpers.sanitize(location).html_safe
	end
end
