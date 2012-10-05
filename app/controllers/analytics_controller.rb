class AnalyticsController < ApplicationController
	before_filter :auth
	layout false

	def auth

		# If the user is not authorized to be here... error
		unless !self.current_user.nil? && self.current_user.is_admin
			raise HTTPStatus::Unauthorized
		end
	end

	def index
		get_all_analytics.each do |slug, data|
			
		end
	end

	def users
		@fields = ['ID', 'Name', 'Email', 'RSVPs', 'Vouches', 'Skills', 'Videos', 'Completion', 'Triggered Analytics']
		@users = User.order('`last_login` DESC').paginate(:page => params[:page], :per_page => 20)

		if request.post?

			# Filter by dates
			unless params[:date_start].nil? || params[:date_end].nil? || params[:date_start].empty? || params[:date_end].empty?
				@users = @users.where('date(`last_login`) BETWEEN ? AND ?', params[:date_start], params[:date_end])
			end

			# Complicated Query
			unless params[:user_type].nil? || params[:user_type].empty?

			end

			# Filter by test types
			unless params[:user_test].nil? || params[:user_test].empty?
				@users = @users.where('`ab` = ?', params[:user_test]) unless params[:user_test] == 'default'
				@users = @users.where('`ab` IS NULL') if params[:user_test] == 'default'
			end

			# Filter by ID Range
			unless params[:range].nil? || params[:range].match(/^[0-9]+~[0-9]+$/).nil?

				# Split start and end
				_start, _end = params[:range].split('~')

				# Get results between
				@users = @users.where('`id` BETWEEN ? AND ?', _start, _end) if _start < _end
			end

			unless params[:complete].nil? || params[:complete].empty?
				complete = params[:complete]

				if !(match = complete.match(/(^[0-9]{1,3}).$/)).nil?
					operator = complete.gsub(match.to_s, '')

					# If there was an operator
					operator = '=' if operator.empty?
					@users = @users.where("? #{operator} `completion`", match.to_s)
				elsif !(match = complete.match(/(^[0-9]{1,2})-([0-9]{1,3}$)/)).nil?

					# Split the start and end
					_start, _end = match.to_a.delete_if{|x| x == complete}

					# Get results between
					@users = @users.where('`completion` BETWEEN ? AND ?', _start, _end) if _start < _end
				end
			end
		end

	end

	def slug
		@fields = ['Slug', 'Class', 'ID', 'User who triggered', 'Times triggered', 'Average times triggered per week', 'Date']
		@slug = self.get_analytics(params[:slug], nil, params[:date_start], params[:date_end]) do |s|

			# Get the total times the event was fired by this user
			join = Analytic.select('`user_id`, COUNT(*) as `count`').where(:slug => params[:slug]).group('`slug`, `user_id`, `tag`').to_sql

			# Get Average Per Week
			groupweek = Analytic.select('`user_id`, COUNT(*) as `per_week`, YEARWEEK(`created_at`) as `column_to_group_by`').where(:slug => params[:slug]).group('`slug`, `user_id`, `tag`, `column_to_group_by`').to_sql
			join1 = "SELECT `user_id`, ROUND(AVG(`per_week`)) as `per_week` FROM (#{groupweek}) as `sub` GROUP BY `user_id`"

			# Get the actual data and join it all
			s = s.select('`analytics`.*, `tmp`.`count`, CEIL(`tmp`.`count` / `tmp1`.`per_week`) as `per_week`, `analytics`.`id` as `group_by`').joins("LEFT JOIN (#{join}) as `tmp` ON `analytics`.`user_id` = `tmp`.`user_id` LEFT JOIN (#{join1}) as `tmp1` ON `analytics`.`user_id` = `tmp1`.`user_id`")
			s = s.where('`analytics`.`user_id` IS NOT NULL').group('`group_by`').order('`created_at` DESC')

			# Pagination
			s = s.paginate_by_sql([s.to_sql], :page => params[:page], :per_page => 20)
		end
	end

	def user
		@fields = ['Slug', 'Class', 'ID', 'Date']
		@user = User.find(params[:id])

		@slug = self.get_analytics(nil, nil, params[:date_start], params[:date_end]) do |s|

			# Get slugs only for this user
			s = s.where('`user_id` = ?', params[:id])
			s = s.paginate(:page => params[:page], :per_page => 20)
			s = s.order('`created_at` DESC')
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
			ActiveRecord::Base.connection.execute("SELECT `slug` FROM `analytics` WHERE `slug` IS NOT NULL && `slug` != '' GROUP BY `slug`").each do |x|
				slugs << x.first
			end

			# Loop through the slugs and get the results
			results = Hash.new; slugs.each do |slug|
				results[slug] = self.get_analytics(slug, nil, date_start, date_end, unique)
			end

			# Results
			return results
		end
end
