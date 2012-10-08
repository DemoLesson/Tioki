# Connection Depth Var
CONNECTION_DEPTH = Array.new

class Connection < ActiveRecord::Base
	belongs_to :user
	belongs_to :owner, :foreign_key => :owned_by
	scope :not_pending, where(:pending => false)

	# Get information on my connections
	def self.mine(args = {})
		
		# Set the user to lookup
		a = User.current.id if args[:user].nil?
		a = args[:user] unless args[:user].nil?

		# Get only the connections I instigated
		unless args[:creator].nil?
			tmp = self.where('`owned_by` = ?', a) if args[:creator]
			tmp = self.where('`user_id` = ?', a) unless args[:creator]
		end

		# Get all connections involving me
		tmp = self.where('`owned_by` = ? || `user_id` = ?', a, a) if args[:creator].nil?

		# Set pending true or false
		tmp = tmp.where('`pending` = ?', args[:pending]) unless args[:pending].nil?

		# Return the modified object
		return tmp
	end

	# Get information on another user
	def self.user(user_id)
		self.mine(:user => user_id, :pending => false)
	end

	def self.find_for_user(user_id)
		Connection.find(:all, :conditions => ['owned_by = ?', user_id])
	end

	def not_me(user_id = nil)
		user_id = User.current.id if user_id.nil?
		User.find(self.owned_by.to_i == user_id.to_i ? self.user_id : self.owned_by)
	end

	def owner
		User.find(self.owned_by)
	end

	def icreated?
		User.current.id == self.owned_by ? true : false
	end

	def self.add_connect(current_user_id, user_id)

		# Get users as A and B
		a = current_user_id
		b = user_id

		# Get a previous connection attempt
		@previous = Connection.where('(`owned_by` = ? && `user_id` = ?) || (`user_id` = ? && `owned_by` = ?)', a, b, a, b).first

		# If no previous one connect
		if @previous == nil

			# Create the connection
			@connection = Connection.new
			@connection.owned_by = current_user_id
			@connection.user_id = user_id

			# If everything saved ok
			if @connection.save
				
				# Notify the other user of my connection request
				UserMailer.userconnect(current_user_id, user_id).deliver
				return true
			else
				return false
			end

		# If this user did not instigate original connection go ahead and connect
		elsif @previous.pending == true && @previous.user_id == a
			@previous.pending = false

			if @previous.save
				Whiteboard.createActivity(:user_connection, "{user.teacher.profile_link} just connected with {tag.teacher.profile_link} you should too!", User.find(a == @connect.user_id ? @connect.owned_by : @connect.user_id))
				self.log_analytic(:user_connection_accepted, "Two users connection", @previous)

				return true
			else 
				return false
			end
		else
			return false
		end
	end

	def self.distance(id = nil, level = 1, connections = nil, user_id = nil, delve = false)

		# Default
		result = nil

		# Make id an Fixnum
		id = id.to_i

		# Dont go too deep
		return nil if level >= 5

		# Require Nil
		raise StandardError, "You must provide a target id" if id.nil?

		# My Connections
		connections = Connection.mine(:pending => false) if connections.nil?

		# Begin with me and remove myself from additional searching
		if user_id.nil?
			user_id = User.current.id
			CONNECTION_DEPTH << user_id
		end

		# Look at immediate
		if !delve || level <= 1
			connections.each do |c|

				# If we found the id then stop
				if id == c.user_id || id == c.owned_by
					result = level
					break
				end
			end
		end

		# Return unless result is still nil
		return result unless result.nil?
		
		# If @level is null && we want to delve
		if (delve || level <= 1) && result.nil?

			# Search immediate connections
			connections.each do |c|

				# Get the user not me
				c = c.not_me(user_id)

				# If we already scanned this user then dont continue
				next if CONNECTION_DEPTH.include? c.id

				connections = Connection.mine(:user => c.id, :pending => false)

				# Get the distance down
				result = self.distance(id, level + 1, connections, c.id, false) 

				# Return unless were on the base or @level is still nil
				return result unless result.nil?
			end

			# Still no results GAH!
			if result.nil?
				
				# Delve down the connections stack
				connections.each do |c|

					# Get the user not me
					c = c.not_me(user_id)

					# If we already scanned this user then dont continue
					next if CONNECTION_DEPTH.include? c.id
					CONNECTION_DEPTH << c.id

					connections = Connection.mine(:user => c.id, :pending => false)

					# Get the distance down
					result = self.distance(id, level + 1, connections, c.id, true) 

					# Return unless were on the base or @level is still nil
					return result unless result.nil?
				end
			end
		end

		# Return result
		return result
	end
end
