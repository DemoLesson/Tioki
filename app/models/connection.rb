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
end
