class MetricsController < ApplicationController
	layout false
	before_filter :auth

	def auth

		# If the user is not authorized to be here... error
		unless !self.current_user.nil? && self.current_user.is_admin
			raise HTTPStatus::Unauthorized
		end
	end

	def index

		# Create graphs hash
		@graphs = {
			"local" => Hash.new,
			"mailgun" => Hash.new
		}

		# Load up all graphs
		get_all_analytics.each do |s,a|

			# Break up the data
			alt = Hash.new
			a.delete_if do |ab|

				# If there is no AB
				next false if ab.user.nil? || ab.user.ab.nil?
				
				# Create the ab array is not exists
				unless alt[ab.user.ab].is_a?(Array)
					alt[ab.user.ab] = Array.new
				end

				# Append the analytic to the ab array
				alt[ab.user.ab] << ab
				next true
			end

			# If the key is nil continue
			next if s.nil?

			# Normal data
			@graphs["local"][s] = Hash.new
			@graphs["local"][s][:slug] = s.gsub(/[\[\]]/, '')
			@graphs["local"][s][:name] = s.gsub(/[_]/, ' ').capitalize
			@graphs["local"][s][:data] = Hash.new
			@graphs["local"][s][:data]['default'] = flotter a

			# Alternate data
			alt.each do |k,b|
				@graphs["local"][s][:data][k] = flotter b
			end
		end

		# Mailgun stats
		_mailgun_stats('all', nil, Time.new.last_week).each do |s,d|
		  next if s.nil?
			s = s.to_s
			@graphs["mailgun"][s] = Hash.new
			@graphs["mailgun"][s][:slug] = s.gsub(/[\[\]]/, '')
			@graphs["mailgun"][s][:name] = s.gsub(/[_]/, ' ').capitalize
			@graphs["mailgun"][s][:data] = Hash.new
			@graphs["mailgun"][s][:data]['default'] = flotter d
		end

		# Load up all stats
		@stats = Hash.new
		get_stats.each do |s,d|

			# If the key is nil continue
			next if s.nil?

			# Normal data
			@stats[s] = Hash.new
			@stats[s][:slug] = s.gsub(/[\[\]]/, '')
			@stats[s][:name] = s.gsub(/[_]/, ' ').capitalize
			@stats[s][:data] = d
		end
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
			results = Hash.new
			slugs.each do |slug|
				results[slug] = self.get_analytics(slug, nil, date_start, date_end, unique) do |a|
					a = a.select('count(date(`created_at`)) as `views_per_day`, unix_timestamp(date(`created_at`)) as `view_on_day`, `user_id`')
					a = a.group('date(`created_at`)')
				end
			end

			# Clean
			results.clean!

			return results
		end

		def get_stats
			# Get the database connection
			db = ActiveRecord::Base.connection

			stats = Hash.new
			stats["pending_connections"] = db.execute("SELECT COUNT(*) as 'count' FROM `connections` WHERE `pending` = '1'").to_a.first.first
			stats["teacher_connections"] = db.execute("SELECT COUNT(*) as 'count' FROM `connections` WHERE `pending` = '0'").to_a.first.first
			stats["registered_users"] = db.execute("SELECT COUNT(*) as 'count' FROM `users`").to_a.first.first
			stats["videos"] = db.execute("SELECT COUNT(*) as 'count' FROM `videos`").to_a.first.first
			stats["total_vouches"] = db.execute("SELECT COUNT(*) as 'count' FROM `vouches`").to_a.first.first
			stats["published_events"] = db.execute("SELECT COUNT(*) as 'count' FROM `events` WHERE `published` = '1'").to_a.first.first
			stats["pending_events"] = db.execute("SELECT COUNT(*) as 'count' FROM `events` WHERE `published` = '0'").to_a.first.first
			stats["active_jobs"] = db.execute("SELECT COUNT(*) as 'count' FROM `jobs` WHERE `active` = '1'").to_a.first.first
			stats["inactive_jobs"] = db.execute("SELECT COUNT(*) as 'count' FROM `jobs` WHERE `active` = '0'").to_a.first.first
			stats["viewed_job_applications"] = db.execute("SELECT COUNT(*) as 'count' FROM `applications` WHERE `viewed` = '1'").to_a.first.first
			stats["unviewed_job_applications"] = db.execute("SELECT COUNT(*) as 'count' FROM `applications` WHERE `viewed` = '0'").to_a.first.first
			stats["interviews"] = db.execute("SELECT COUNT(*) as 'count' FROM `interviews`").to_a.first.first
			return stats
		end

		def _mailgun_stats(event = "all", limit = nil, start = nil)
			url_params = Multimap.new

			# Get the limit 
			url_params[:limit] = limit unless limit.nil?

			# Set the start date
			url_params[:start] = start.utc.strftime("%Y-%m-%d") unless start.nil?

			# Get Events
			if event.respond_to?("each")
				event.each do |e|
					url_params[:event] = e
				end
			elsif event.is_a?(String) && !event == 'all'
				url_params[:event] = event
			end

			key = "key-8xdgggqce58b-0wjv2d0jf9wvic6qet8"
			domain = "demolesson.com.mailgun.org"

			# Generate Query String and Call
			query_string = url_params.collect {|k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join("&")
			stats = JSON.parse(RestClient.get "https://api:#{key}@api.mailgun.net/v2/#{domain}/stats?#{query_string}")

			process = Hash.new
			stats["items"].each do |x|

				# Parse the time and get a timestamp as a string
				time = Time.parse(x["created_at"]).to_i.to_s

				# If the hash key has not already been created go ahead and created it
				process[x["event"].to_sym] = Hash.new if process[x["event"].to_sym].nil?

				# Add the amount for the specified date
				process[x["event"].to_sym][time] = x["total_count"]
			end

			# Clean
			process.clean!

			return process
		end
end
