class Connection < ActiveRecord::Base
	belongs_to :user, :counter_cache => true
	belongs_to :owner, :class_name => "User", :foreign_key => :owned_by, :counter_cache => true
	scope :not_pending, where(:pending => false)
	scope :pending, where(:pending => true)
	after_create :create_reminder

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

  # @todo deprecate .mine() does roughly the same thing
	def self.find_for_user(user_id)
		Connection.where('owned_by = ?', user_id).all
	end

	def not_me(_user_id = nil)
		begin
			_user_id = User.current.id if _user_id.nil?
			user = self.owned_by.to_i == _user_id.to_i ? self.user : self.owner
		rescue ActiveRecord::RecordNotFound => e
			self.destroy
			return redirect_to request.path
		end

		# Log the connection
		#Rails.logger.info "Connection.rb Method `not_me` Accessed on (#{id}): #{self.user.class}:#{self.user.id rescue '*'} <-> #{self.owner.class}:#{self.owner.id rescue '*'}"

		return user
	end

	# Just return id
	def not_me_id(_user_id = nil)
		_user_id = User.current.id if _user_id.nil?
		self.owned_by == _user_id ? self.user_id : self.owned_by
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
				# If the user has agreed to receive connection requests
				# The email permissions tier is backwards false is true etc...
				if !User.find(user_id).email_permissions.connection_requests
					UserMailer.userconnect(current_user_id, user_id).deliver
				end

				return true
			else
				return false
			end

		# If this user did not instigate original connection go ahead and connect
		elsif @previous.pending == true && @previous.user_id == a
			@previous.pending = false

			if @previous.save
				Whiteboard.createActivity(:connection, "{user.link} just connected with {tag.link} you should too!",
					User.find(a == @connect.user_id ? @connect.owned_by : @connect.user_id))
				self.log_analytic(:user_connection_accepted, "Two users connection", @previous)

				return true
			else 
				return false
			end
		else
			return false
		end
	end

	def remind
		owner_id = self.owned_by
		user_id = self.user_id
		if self.pending
			NotificationMailer.connection_reminder(user_id, owner_id).deliver
		end
	end

	def create_reminder
		self.delay({:run_at=> 1.minute.from_now}).remind
	end
end
