class Notification < ActiveRecord::Base

	# By default ignore records with 0 as the type
	default_scope where("`notifications`.`notifiable_type` != '0'")

	# Relationships
	belongs_to :triggered, :class_name => 'User'
	belongs_to :user

	# Cleanup of the db
	after_find :remove_unused
	def remove_unused

		# Get the notifiable type
		_class = notifiable_type.split(':').first

		# Delete the record if it maps to nothing
		destroy if map_tag if map_tag.nil?

		# If the class is not destroyed consider destroying
		if !destroyed?
			begin
				case _class
					when 'Application'
						destroy if map_tag.job.nil?
					when '0'
						destroy
				end
			rescue ActiveRecord::RecordNotFound
				destroy
			rescue Exception => e
				puts e.message
				raise e
			end
		end
	end

	# Mapped relationships
	def map_tag
		# Return the object in question
		begin; return mapTag!(self.notifiable_type)
		
		# If the notifiable object does not exist destroy the notification
		rescue ActiveRecord::RecordNotFound
			self.destroy
			return nil
		end
	end

	def self.mine(conds = {})
		user = User.current if conds[:user].nil?
		user = conds[:user] unless conds[:user].nil?
		user = User.find(user) if user.is_a?(Fixnum)

		conds[:order] = 'DESC' if conds[:order].nil?

		query = self.where('`notifications`.`user_id` = ?', user.id)
		query = query.order("`notifications`.`created_at` #{conds[:order]}")
		query = query.where('`notifications`.`dashboard` = ?', conds[:dashboard]) unless conds[:dashboard].nil?
		return query
	end

	def self.notify!(digest = false, digestInterval = 86400)

		# If all the notifications have never been sent then dont send anything older then an hour
		where('`created_at` < ?', 1.day.ago).update_all(:emailed => true) if where(:emailed => true).count < 1

		# Hash table for storing users notifications
		user_notifications = Multimap.new

		# If this is a digest get the items to digest
		if digest
			sql_query = where('`bucket` != ?', 'noemail').where('`created_at` BETWEEN ? AND ?', Time.now - digestInterval, Time.now)
		else
			sql_query = where(:emailed => false).where('`bucket` != ?', 'noemail')
		end


		# Sort out the unsent notifications
		for notification in sql_query
			user_notifications[notification.user.id] = notification
		end

		# Deallocate memory
		sql_query = nil

		# For every user determine whether or not to send notifications
		user_notifications.each_association do |user, notifications|

			# Get the user
			user = User.find(user)

			# If were digesting and the user is not subscribed skip it
			if digest
				_tmp = user.notification_intervals.daily
				next if !_tmp.nil? && _tmp < 1
			end

			# Don't filter by buckets unless if were digesting
			unless digest
				# Acknowledge notification intervals
				APP_CONFIG.notification_buckets.each do |bucket|

				# Get the interval for this bucket of notifications
				#interval = user.notification_intervals[bucket] rescue nil
				#interval = 7200

				# Tempoarily disable emails that are non-digest
				interval = 0

				# Set the default bucket interval
				if interval.nil?
					interval = 7200
					user.notification_intervals[bucket] = interval
				end

				# Find out when the last email in this bucket was sent and remove
				# any notifications that we should not send yet
				_tmp = where(:emailed => true, :user_id => user.id, :bucket => bucket)
				if interval == 0 || _tmp.where('`emailed_at` > ?', Time.now - interval).count > 0
					notifications.delete_if{|n|n.bucket==bucket}
				end

				# Deallocate memory
				_tmp = nil
				end
			end

			# Send notifications unless we stripped them all out
			NotificationMailer.summary(user, notifications).deliver unless notifications.empty?

			# Mark each notification as emailed out
			notifications.collect(&:emailed!)

			# Deallocate memory
			notifications = nil
			user = nil
		end

		# Return true
		return true
	end

	def emailed!
		# Set the email as emailed and set the time for reference
		update_attributes(:emailed => true, :emailed_at => Time.now)
	end

	def triggered
		return false if destroyed?

		_triggered = read_attribute :triggered_id

		return User.find(_triggered) if !_triggered.nil?

		_class = notifiable_type.split(':').first

		begin
			_user = case _class
			when 'Message'
				update_attribute :triggered_id, map_tag.user_id_from
				User.find(map_tag.user_id_from)
			else
				update_attribute :triggered_id, map_tag.user_id
				User.find(map_tag.user_id)
			end

			return _user
		rescue ActiveRecord::RecordNotFound
			map_tag.destroy
			destroy
			return nil
		end
	end

	def getMessage(_message = nil)
		return false if destroyed?

		# Get the data to query on
		record = Hash.new
		record["data"] = ActiveSupport::JSON.decode(self.data.nil? ? '{}' : data)
		record["triggered"] = triggered
		record["user"] = user
		record["tag"] = map_tag

		# Get the message unparsed
		# and sanitize anything that isn't a link
		m = ActionController::Base.helpers.sanitize(_message.nil? ? read_attribute(:message) : _message, :tags => %w(a))

		# Get all the variables
		vars = m.scan(/{[\w.(),]+}/)

		# Get ready for the parsed data to go here
		parsed_vars = {}

		# Parse the variables
		vars.each do |var|

			# Save the name for later
			var_name = var

			# Go ahead and split the var
			var = var.gsub(/[{}]/, '').split('.')

			# Generate a scope and iterate through each var segment
			scope = record
			var.each_with_index do |var_seg, var_key|
				# Debugger
				#puts '@__['+var_seg+']: ' + scope.inspect

				# If this is the first key pick from the root hash
				if var_key == 0
					raise StandardError, var_seg + ' is not a root key' unless scope.has_key?(var_seg)
					scope = scope[var_seg] if scope.has_key?(var_seg)
					next
				end

				# Is this next is a hash then process
				if scope.is_a?(Hash)
					raise StandardError, var_seg + ' is not an avilable key' unless scope.has_key?(var_seg)
					scope = scope[var_seg]
					next
				end

				# If the next is a object then process
				if scope.is_a?(Object)

					# If there are arguments then seperate them and split
					args = Array.new
					if var_seg['(']
						var_seg = var_seg.split('(')
						args = var_seg[1].gsub(')', '').split(',')
						var_seg = var_seg[0]
					end

					#raise NoMethodError, var_seg + ' is not an avilable method' unless scope.respond_to?(var_seg)
					scope = scope.send(var_seg, *args)
					next
				end

				# Raise an error
				raise StandardError, "Why are we here"
			end

			# Append to the parsed vars
			parsed_vars[var_name] = scope
		end

		# Replace the var instances with the values
		parsed_vars.each do |var,val|

			# Prepend tioki.com to links
			if var.include?('.link')
				val = val.gsub('href="/', 'href="http://tioki.com/')
			end

			# Replace the link
			m = m.gsub(var,val)
		end

		# Return the new message
		return m.html_safe
	end

	def message
		return false if destroyed?

		# @todo deprecate on Jan 31, 2013
		_message = read_attribute(:message)
		begin
			# Return the message
			return getMessage(_message).html_safe if !_message.nil?
		rescue NoMethodError => e
			return e.message
		end

		_class = notifiable_type.split(':').first

		ret = String.new
		case _class
		when 'Comment'
			ret = "{triggered.link} replied to a discussion."
		when 'Discussion'
			ret = "{triggered.link} created a discussion on {tag.owner.link} go read {tag.link}."
		when 'Favorite'
			ret = "{triggered.link} favorited a post of yours."
		when 'Application'
			ret = "{triggered.link(resume)} has applied to {tag.job.link}" if dashboard == 'recruiter'
			ret = "{triggered.link(resume)} has applied to {tag.job.link}" if dashboard != 'recruiter'
		when 'Interview'
			ret = "{triggered.link(resume)} responded to the interview request for {tag.job.link}" if dashboard == 'recruiter'
			ret = "{triggered.link(resume)} updated a interview request for {tag.job.link}" if dashboard != 'recruiter'
		when 'Message'
			ret = "{triggered.link(resume)} sent you a message."
		end

		# Write the message to the Database
		update_attribute(:message, ActionController::Base.helpers.sanitize(ret))

		begin
			# Return the message
			return getMessage(ret).html_safe
		rescue NoMethodError
			return false
		end
	end

	def link
		return false if destroyed?

		# @todo deprecate on Jan 31, 2013
		_link = read_attribute(:link)
		return _link if !_link.nil?

		begin
			ret = map_tag.url rescue nil

			# Write the link to the Database
			update_attribute(:link, ret)
		rescue Exception
		end

		return ret
	end

	def bucket
		return false if destroyed?

		# @todo deprecate on Jan 31, 2013
		_bucket = read_attribute(:bucket)
		return _bucket if !_bucket.nil?

		_class = notifiable_type.split(':').first

		begin
			case _class
			when 'Comment', 'Discussion'
				ret = :discussions
			when 'Application', 'Interview'
				ret = :jobs
			when 'Favorite'
				ret = :favorites
			when 'Message'
				ret = :noemail
			end

			# Write the bucket to the DB
			update_attribute(:bucket, ret.to_s)
		rescue Exception
		end

		return ret.to_s
	end

	def self.profile_views
		#Get profile view analytics from the last week
		users = Analytic.where("analytics.created_at > ? && analytics.slug = ?",
		                       Time.now-7.days,
		                       "view_user_profile").collect(&:map_tag).uniq

		users.each do |user|
			views = Analytic.where("analytics.created_at > ? && analytics.slug = ? && analytics.tag = ?",
			                       Time.now-7.days,
			                       "view_user_profile",
			                       user.tag!).collect(&:user).uniq

			NotificationMailer.profile_views(user, views).deliver
		end
	end
end
