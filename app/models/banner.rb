class Banner < ActiveRecord::Base
	def self.current(limit = 1)

		# If the banner is dismissed dont show
		return [] if cookies[:tioki_banner_dismissed] == "true"

		day = Time.now.wday
		day = 7 if day == 0
		result = where("? BETWEEN `start` AND `stop` || (date(?) = date(`start`) && `stop` IS NULL) || `recurring` = ?", Time.now, Time.now, day).order('`recurring` ASC').limit(limit).all
	end

	def timeframe
		from = start
		to = stop

		dateformat = String.new
		dateformat = '%l:%M%P %Z' unless to.nil?
		dateformat = '%m/%d/%Y ' + dateformat if recurring.nil?

		ret = from.strftime(dateformat)
		ret << " to " + to.strftime(dateformat) unless to.nil?
		ret << "All Day" if to.nil?

		return ret
	end

	def recurring_day
		return 'Non Recurring' if recurring.nil?
		return 'Mondays' if recurring == 1
		return 'Tuesdays' if recurring == 2
		return 'Wednesdays' if recurring == 3
		return 'Thursdays' if recurring == 4
		return 'Fridays' if recurring == 5
		return 'Saturdays' if recurring == 6
		return 'Sundays' if recurring == 7
	end

	def message
  		read_attribute(:message).html_safe
	end
end