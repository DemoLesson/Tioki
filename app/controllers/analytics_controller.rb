class AnalyticsController < ApplicationController
	layout false
	before_filter :auth

	def auth

		# If the user is not authorized to be here... error
		unless !self.current_user.nil? && self.current_user.is_admin
			raise HTTPStatus::Unauthorized
		end
	end

	def index
		dump get_all_analytics
	end

	def flotter(s)
		# Parse all the dates
		save_time = nil
		dates = Array.new

		# Loop through the actual query results
		s.each do |x|
			time = Time.at(x.view_on_day) if x.respond_to?('view_on_day')
			time = Time.at(x.first.to_i) unless x.respond_to?('view_on_day')

			# If save time is nil ignore
			unless save_time.nil?
				i = 1

				# Set the last time we had for adjusting
				adjust_time = save_time

				# Create empty days of zero if no days are logged
				while i < (time.to_date - save_time.to_date)

					# Adjust the time forward to the next day
					adjust_time = adjust_time.tomorrow

					# Get the right time in seconds (with the utc offset for the timezone)
					tmp = (adjust_time.to_time.localtime.to_i + adjust_time.to_time.localtime.utc_offset) * 1000

					# Add the date to the array of dates
					dates << "[#{tmp}, 0]"

					# Increase the pointer for the while llop
					i += 1
				end
			end

			# Set save time for any more upcoming loops
			save_time = time

			# Get the right time in seconds of a hit (witht the utc offset for the timezone)
			view_on_day = (time.localtime.to_i + time.localtime.utc_offset) * 1000

			# Add the date to the array of dates
			dates << "[#{view_on_day}, #{x.views_per_day}]" if x.respond_to?('views_per_day')
			dates << "[#{view_on_day}, " + x.last.to_s + "]" unless x.respond_to?('views_per_day')
		end

		# Join the data indo an output array
		dates.join(',')
	end

	private

		def get_all_analytics(date_start = nil, date_end = nil, unique = false)

			# Get a list of all the slugs in the DB
			slugs = Array.new
			ActiveRecord::Base.connection.execute("SELECT `slug` FROM `analytics` GROUP BY `slug`").each do |x|
				slugs << x.first
			end

			# Loop through the slugs and get the results
			return self.get_analytics(slug, nil, date_start, date_end, unique)
		end
end
