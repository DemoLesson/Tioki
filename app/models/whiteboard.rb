class Whiteboard < ActiveRecord::Base
	
	belongs_to :user
	has_and_belongs_to_many :whiteboard_hidden, :class_name => 'User', :join_table => 'whiteboards_hidden'

	# Comments integration
	acts_as_commentable

	# Add support for getting comments
	def getComments
		self.root_comments
	end

	# Create a Comment
	def createComment(body)
		Comment.build_from(self, User.current.id, body)
	end

	def map_tag
		mapTag!(self.tag)
	end

	def tag!
		self.map_tag
	end

	def data!
		ActiveSupport::JSON.decode(self.data.nil? ? '{}' : self.data)
	end

	def getMessage

		# Get the data to query on
		record = Hash.new
		record["data"] = ActiveSupport::JSON.decode(self.data.nil? ? '{}' : self.data)
		record["user"] = self.user
		record["tag"] = self.map_tag

		# Get the message unparsed
		m = self.message

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
			var.each_with_index do |var_seg,var_key|

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

					raise StandardError, var_seg + ' is not an avilable method' unless scope.respond_to?(var_seg)
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
			m = m.gsub(var,val)
		end

		# Get any screencaps
		if record["data"].has_key?("screens")
			record["data"]["screens"].each do |k,v|
				m << "<a href=\"#{k}\" target=\"_blank\" class=\"item_picture\"><img src=\"#{v}\" style=\"width:150px;\" /></a>"
			end
		end

		# Return the new message
		return m.html_safe
	end

	def getModels
		[self.user, self.map_tag]
	end

	# #
	### Get activity data
	# #
	def self.getActivity(hidden = true)

		# Get the current user
		currentUser = User.current
		list_1 = Connection.select("`owned_by` as 'user'").where("`user_id` = ? AND `pending` = '0'", currentUser.id).to_sql
		list_2 = Connection.select("`user_id` as 'user'").where("`owned_by` = ? AND `pending` = '0'", currentUser.id).to_sql
		
		# Get the list of your connected users
		db = ActiveRecord::Base.connection();
		connections = db.execute(list_1 + " UNION " + list_2).to_a;

		# Pop off the row data and append the current user
		connections.collect!{|d| d.pop}
		connections << currentUser.id

		# Remove duplicates and turn into CSV
		connections = connections.delete_if {|x| x.nil?}
		tags = "'User:" + connections.uniq.join("','User:") + "'"
		connections = "'" + connections.uniq.join("','") + "'"

		# Temporary slug allowance list
		slugs = ['share','event_rsvp','event_create']
		slugs = "'" + slugs.join("','") + "'"

		# Temporary script
		query = ["(`whiteboards`.`user_id` IN (#{connections}) || `whiteboards`.`tag` IN (#{tags}))"]
		query << "(`whiteboards`.`slug` IN (#{slugs}))"
		query = self.where(query.join(' || ')).order('`created_at` DESC')

		# Generate the default query
		# Temporarily disabled so we can show all events
		# query = self.where("`whiteboards`.`user_id` IN (#{connections}) || `whiteboards`.`tag` IN (#{tags})").order('`created_at` DESC')

		# Remove the hidden Items
		if hidden

			# Start working on a new DB connection
			ids = self.select("`whiteboards`.`id`")

			# Start by joining with the hiddens tables and getting the data side by side
			ids = ids.joins("RIGHT JOIN `whiteboards_hidden` ON `whiteboards`.`id` = `whiteboards_hidden`.`whiteboard_id`")

			# Go ahead and limit the tables results down to the ones we care about rather then getting hidden data on all of them
			ids = ids.where("`whiteboards`.`user_id` IN (#{connections}) || `whiteboards`.`tag` IN (#{tags})")

			# Now filter down the hidden rresults by limiting the data to the active user
			ids = ids.where("`whiteboards_hidden`.`user_id` = '#{currentUser.id}'").to_sql

			# Since we cant use NOT IN then go ahead and join on the data and select all the ones that don't have joins
			query = query.joins("LEFT JOIN (#{ids}) as `tmp` ON `tmp`.`id` = `whiteboards`.`id`").where("`tmp`.`id` IS NULL")
		end

		# Return the modified default query
		return query
	end

	def self.getMyActivity

		# Get the current user
		currentUser = User.current

		# Get all the activity
		self.where("`user_id` = ? || `tag` = ?", currentUser.id, currentUser.tag!)
	end

	def self.createActivity(slug, message, tag = '', data = {})

		# If a string was passed in then post always
		if slug.is_a?(Symbol)
			post_always = false
		else
			post_always = true
		end

		# Get rid of the current user if nil
		currentUser = User.current
		return false if currentUser.nil?

		# Get the tag of the passed tag model
		tag = tag.tag! if tag.is_a?(ActiveRecord::Base)

		unless post_always
			# Dont allow a duplicate message to be posted within the same hour
			whiteboard = ["`whiteboards`.`user_id` = '#{currentUser.id}'"]
			whiteboard << "`whiteboards`.`slug` = '#{slug}'"
			whiteboard1 = whiteboard.clone
			whiteboard << "`whiteboards`.`tag` = '#{tag}'"
			whiteboard << "(`whiteboards`.`tag` != '' && `whiteboards`.`tag` IS NOT NULL)"
			whiteboard1 << "(`whiteboards`.`tag` = '' || `whiteboards`.`tag` IS NULL)"
			whiteboard = '(' + whiteboard.join(' && ') + ') || (' + whiteboard1.join(' && ') + ')'
			whiteboard = Whiteboard.where(whiteboard)
			whiteboard = whiteboard.where("", slug)
			whiteboard = whiteboard.where(
				'`whiteboards`.`created_at` BETWEEN ? AND ?',
				(Time.now - 3600).utc.strftime("%Y-%m-%d %H:%M:%S"),
				(Time.now + 60).utc.strftime("%Y-%m-%d %H:%M:%S")
			).count

			# Return if is a duplicate
			return "Duplicate within hour" if whiteboard > 1
		end

		# Extract links from the message
		addData = Hash.new
		addData["urls"] = Array.new
		message.scan(URI.regexp(['http', 'https'])) do |*m|
			addData["urls"] << $&
		end

		# Create links and screenshots
		addData["screens"] = Hash.new
		addData["urls"].each do |u|
			message = message.gsub("#{u}", "<a href=\"#{u}\">#{u}</a>")
			addData["screens"].merge!({u => "http://api.snapito.com/web/2082a962d90ebd047fe4671d5146b73803c3e239/sc?url=#{u}"})
		end

		# Merge in the data
		data.merge!(addData)

		# Create new activity instance
		w = new
		w.slug = slug.to_s
		w.user = currentUser
		w.message = message
		w.tag = tag
		w.data = ActiveSupport::JSON.encode(data)
		w.save
	end
end
