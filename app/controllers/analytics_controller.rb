class AnalyticsController < ApplicationController
	before_filter :auth
	layout false

	def auth

		# If the user is not authorized to be here... error
		unless !currentUser.new_record? && self.current_user.is_admin
			raise HTTPStatus::Unauthorized
		end
	end

	def index
	end

	def users
		@fields = ['ID', 'Name', 'Email', 'RSVPs', 'Vouches', 'Skills', 'Videos', 'Connections', 'Completion', 'Triggered Analytics']
		@users = User.order('`last_login` DESC').paginate(:page => params[:page], :per_page => 20)
		@totals = Hash.new
		@totals[:events_rsvps] = EventsRsvps.where("'1' = '1'")
		@totals[:vouched_skills] = VouchedSkill.where("'1' = '1'")
		@totals[:skill_claims] = SkillClaim.where("'1' = '1'")
		@totals[:videos] = Video.where("'1' = '1'")
		@totals[:connections] = Connection.where("`connections`.`pending` = ?", false)
		@totals[:completion] = User.select('CEIL(AVG(`users`.`completion`)) as `_completion`')
		@rawtotals = @totals.clone
		@show_raw = false

		# Store the joined tables
		joined_tables = Multimap.new

		if params[:tname]
			#is it a valid integer?
			if params[:tname].numeric?
				@users = User.where('id = ?', params[:tname]).order('users.created_at DESC').paginate(:page => params[:page], :per_page => 20)
			else
				@users = User.where('name LIKE ?', "%#{params[:tname]}%").order('users.created_at DESC').paginate(:page => params[:page], :per_page => 20)
			end
		end

		if request.post?

			# Filter by dates
			unless params[:date_start].nil? || params[:date_end].nil? || params[:date_start].empty? || params[:date_end].empty?
				@users = @users.where('date(`last_login`) BETWEEN ? AND ?', params[:date_start], params[:date_end])

				# Filter the totals
				@totals.collect! do |key, record|
					next if key == :events_rsvps
					key = :users if key == :completion

					record.where("date(`#{key}`.`created_at`) BETWEEN ? AND ?", params[:date_start], params[:date_end])
				end

				@show_raw = true
			end

			# Complicated Query
			unless params[:user_type].nil? || params[:user_type].empty?
				type = params[:user_type]

				#joins = Hash.new
				#joins.merge!("LEFT JOIN `teachers` ON `users`.`id` = `teachers`.`user_id`" => "`teachers`.`id` IS NOT NULL") if type == 'educator'
				#joins.merge!("LEFT JOIN `schools` ON `users`.`id` = `schools`.`owned_by`" => "`schools`.`id` IS NOT NULL") if type == 'organization'
				#@users = @users.select('`users`.*').joins(joins.keys.join(' ')).where(joins.values.join(' && '))
                
                @users = User.all if type == 'educator'
                
                @users = User.joins(:schools).group('users.id').all if type == 'organization'
                
				# Filter the totals
				@totals.collect! do |key, record|
					next if key == :events_rsvps
					key = :users if key == :completion

					# Perform joins
					joins = Array.new
					condi = Array.new

					#if !joined_tables[key].include?('teachers') && key == :videos
					#	joins << "LEFT JOIN `teachers` ON `videos`.`teacher_id` = `teachers`.`id`"
					#	joined_tables[key] = 'teachers'
					#end

					if !joined_tables[key].include?('users') && key == :videos
						joins << "LEFT JOIN `users` ON `videos`.`user_id` = `users`.`id`"
						joined_tables[key] = 'users'
					elsif !joined_tables[key].include?('users') && key != :users
						joins << "LEFT JOIN `users` ON `#{key}`.`user_id` = `users`.`id`"
						joined_tables[key] = 'users'
					end

					#if type == 'educator' && !joined_tables[key].include?('teachers')
					#	joins << "LEFT JOIN `teachers` ON `users`.`id` = `teachers`.`user_id`"
					#	joined_tables[key] = 'teachers'
					#end

					if type == 'organization' && !joined_tables[key].include?('schools')
						joins << "LEFT JOIN `schools` ON `users`.`id` = `schools`.`owned_by`"
						joined_tables[key] = 'schools'
					end

					#condi << "`teachers`.`id` IS NOT NULL" if type == 'educator'
					condi << "`schools`.`id` IS NOT NULL" if type == 'organization'
					
					record.select("`#{key}`.*").joins(joins.join(' ')).where(condi.join(' && '))
				end

				@show_raw = true
			end

			# Filter by test types
			unless params[:user_test].nil? || params[:user_test].empty?
				@users = @users.where('`users`.`ab` = ?', params[:user_test]) unless params[:user_test] == 'default'
				@users = @users.where('`users`.`ab` IS NULL') if params[:user_test] == 'default'

				@totals.collect! do |key, record|
					next if key == :events_rsvps
					key = :users if key == :completion

					# Join in users
					if !joined_tables[key].include?('users') && key == :videos
						# Join Users
						record = record.joins("LEFT JOIN `users` ON `videos`.`user_id` = `users`.`id`")
						joined_tables[key] = 'users'
					elsif !joined_tables[key].include?('users') && key != :users
						record = record.joins("LEFT JOIN `users` ON `#{key}`.`user_id` = `users`.`id`")
						joined_tables[key] = 'users'
					end

					# Set condition
					record.where('`users`.`ab` IS NULL') if params[:user_test] == 'default'
					record.where('`users`.`ab` = ?', params[:user_test]) unless params[:user_test] == 'default'
				end

				@show_raw = true
			end

			# Filter by ID Range
			unless params[:range].nil? || params[:range].match(/^[0-9]+~[0-9]+$/).nil?

				# Split start and end
				_start, _end = params[:range].split('~')

				# Get results between
				@users = @users.where('`users`.`id` BETWEEN ? AND ?', _start, _end) if _start < _end

				@totals.collect! do |key, record|
					next if key == :events_rsvps
					key = :users if key == :completion

					# Join in users
					if !joined_tables[key].include?('users') && key == :videos
						# Join Users
						joins << "LEFT JOIN `users` ON `videos`.`user_id` = `users`.`id`"
						joined_tables[key] = 'users'
					elsif !joined_tables[key].include?('users') && key != :users
						record = record.joins("LEFT JOIN `users` ON `#{key}`.`user_id` = `users`.`id`")
						joined_tables[key] = 'users'
					end
					
					# Set condition
					record.where('`users`.`id` BETWEEN ? AND ?', _start, _end) if _start < _end
				end

				@show_raw = true
			end

			unless params[:complete].nil? || params[:complete].empty?
				complete = params[:complete]

				if !complete.match(/(^[0-9]{1,3}).$/).nil?

					# Get regex data
					match = complete.match(/(^[0-9]{1,3})/)
					operator = complete.gsub(match.to_s, '')

					# If there was an operator
					operator = '=' if operator.empty?
					@users = @users.where("? #{operator} `users`.`completion`", match.to_s)
				elsif !(match = complete.match(/(^[0-9]{1,2})-([0-9]{1,3}$)/)).nil?

					# Split the start and end
					_start, _end = match.to_a.delete_if{|x| x == complete}

					# Get results between
					@users = @users.where('`users`.`completion` BETWEEN ? AND ?', _start, _end) if _start < _end
				end

				@show_raw = true
			end
		end

		respond_to do |format|
			format.xlsx {
				p = Axlsx::Package.new
				wb = p.workbook
				wb.add_worksheet(:name => "Basic Worksheet") do |sheet|
					sheet.add_row @fields

					# Add Totals
					row = Array.new
					row << '*'
					row << 'All'
					row << 'N/A'
					row << @totals[:events_rsvps].count
					row << @totals[:vouched_skills].count
					row << @totals[:skill_claims].count
					row << @totals[:videos].count
					row << @totals[:connections].count
					row << @totals[:completion].first._completion
					row << 'N/A'
					sheet.add_row row

					@users.each do |user|
						row = Array.new
						row << user.id
						row << user.name
						row << user.email
						row << user.rsvp.count unless @show_raw
						row << user.rsvp.where('`created_at` BETWEEN ? AND ?', params[:date_start], params[:date_end]).count if @show_raw
						row << user.vouched_skills.count unless @show_raw
						row << user.vouched_skills.where('`created_at` BETWEEN ? AND ?', params[:date_start], params[:date_end]).count if @show_raw
						row << user.skills.count unless @show_raw
						row << user.skills.where('`created_at` BETWEEN ? AND ?', params[:date_start], params[:date_end]).count if @show_raw
						row << user.videos.count rescue 0 unless @show_raw
						row << user.videos.where('`created_at` BETWEEN ? AND ?', params[:date_start], params[:date_end]).count rescue 0 if @show_raw
						row << user.connections.count unless @show_raw
						row << user.connections.where('`created_at` BETWEEN ? AND ?', params[:date_start], params[:date_end]).count if @show_raw
						row << user.completion
						row << user.analytics.where('`slug` IS NOT NULL').group('slug').collect!{|x| x.slug}.join(', ')

						sheet.add_row row
					end
				end

				# Get Stream
				return send_data(p.to_stream().read, :filename => "users_export_#{Time.now.strftime("%m-%d-%Y-%H-%I-%S")}.xlsx", :type => Mime::XLSX)
			}
			format.html {
				render :users
			}
		end
	end

	def slugs

		# Get the fields that we will be outputting
		@fields = ['Slug', 'Last Triggered By', 'Last Triggerd', 'Times Triggered']

		# Count and select the slugs, dates that matter
		slugs2 = Analytic.select('COUNT(*) as `times_triggered`, MAX(`analytics`.`created_at`) as `max`, `slug`')
		slugs2 = slugs2.where('`slug` IS NOT NULL').group('`analytics`.`slug`').to_sql

		# Prep the data for the dirty work
		@slugs = Analytic.select('`tmp`.`times_triggered`, `analytics`.*').order('`analytics`.`created_at` DESC')
		
		# Hash of joining data
		slugs_joined = Hash.new

		# Join in the data that matters to narrow down the actual queried query
		slugs_joined.merge!("INNER JOIN (#{slugs2}) as `tmp` ON `analytics`.`created_at` = `tmp`.`max` && `analytics`.`slug` = `tmp`.`slug`" => "'1' = '1'")

		# Store the joined tables
		#joined_tables = Multimap.new

		if request.post?

			# Filter by dates
			unless params[:date_start].nil? || params[:date_end].nil? || params[:date_start].empty? || params[:date_end].empty?
				@slugs = @slugs.where('date(`analytics`.`created_at`) BETWEEN ? AND ?', params[:date_start], params[:date_end])

			end

			# Complicated Query
			unless params[:user_type].nil? || params[:user_type].empty?
				type = params[:user_type]

				slugs_joined.merge!("LEFT JOIN `users` ON `analytics`.`user_id` = `users`.`id`" => "'1' = '1'")
				#slugs_joined.merge!("LEFT JOIN `teachers` ON `users`.`id` = `teachers`.`user_id`" => "`teachers`.`id` IS NOT NULL") if type == 'educator'
				slugs_joined.merge!("LEFT JOIN `schools` ON `users`.`id` = `schools`.`owned_by`" => "`schools`.`id` IS NOT NULL") if type == 'organization'

			end

			# Filter by test types
			unless params[:user_test].nil? || params[:user_test].empty?
				slugs_joined.merge!("LEFT JOIN `users` ON `analytics`.`user_id` = `users`.`id`" => "'1' = '1'")
				@slugs = @slugs.where('`users`.`ab` = ?', params[:user_test]) unless params[:user_test] == 'default'
				@slugs = @slugs.where('`users`.`ab` IS NULL') if params[:user_test] == 'default'

			end

			# Filter by User ID Range
			unless params[:range].nil? || params[:range].match(/^[0-9]+~[0-9]+$/).nil?

				# Split start and end
				_start, _end = params[:range].split('~')

				# Get results between
				slugs_joined.merge!("LEFT JOIN `users` ON `analytics`.`user_id` = `users`.`id`" => "'1' = '1'")
				@slugs = @slugs.where('`users`.`id` BETWEEN ? AND ?', _start, _end) if _start < _end

			end

			unless params[:complete].nil? || params[:complete].empty?
				complete = params[:complete]

				# Join in users
				slugs_joined.merge!("LEFT JOIN `users` ON `analytics`.`user_id` = `users`.`id`" => "'1' = '1'")

				if !complete.match(/(^[0-9]{1,3}).$/).nil?

					# Get regex data
					match = complete.match(/(^[0-9]{1,3})/)
					operator = complete.gsub(match.to_s, '')

					# If there was an operator
					operator = '=' if operator.empty?
					@slugs = @slugs.where("? #{operator} `users`.`completion`", match.to_s)
				elsif !(match = complete.match(/(^[0-9]{1,2})-([0-9]{1,3}$)/)).nil?

					# Split the start and end
					_start, _end = match.to_a.delete_if{|x| x == complete}

					# Get results between
					@slugs = @slugs.where('`users`.`completion` BETWEEN ? AND ?', _start, _end) if _start < _end
				end

				@show_raw = true
			end
		end

		# Process the joins
		@slugs = @slugs.joins(slugs_joined.keys.delete_if{|x| x.numeric? || x.empty?}.join(' ')).where(slugs_joined.values.delete_if{|x| x.empty? || x == "'1' = '1'"}.join(' && '))

		# Pagination Hack
		@slugs = @slugs.paginate_by_sql([@slugs.to_sql], :page => params[:page], :per_page => 20)
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

			# Filter by dates
			unless params[:date_start].nil? || params[:date_end].nil? || params[:date_start].empty? || params[:date_end].empty?
				s = s.where('date(`created_at`) BETWEEN ? AND ?', params[:date_start], params[:date_end])
			end

			unless params[:slug_name].nil? || params[:slug_name].empty?
				s = s.where('`slug` = ?', params[:slug_name])
			end

			# Get slugs only for this user
			s = s.where('`user_id` = ?', params[:id])
			@slug_count = s.count
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
end
