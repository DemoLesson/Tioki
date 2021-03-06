class Message < ActiveRecord::Base
	attr_accessible :user_id_to, :user_id_from, :read, :subject, :body, :tag, :replied_to_id, :replied_at, :assets_attributes
	validates_presence_of :subject, :body, :message => "Please enter a subject and/or message."

	has_many :replied_messages, :class_name => "Message", :foreign_key => "replied_to_id", :dependent => :nullify
	belongs_to :message, :foreign_key => :replied_to_id

	has_many :assets, :as => :owner, :dependent => :destroy
	accepts_nested_attributes_for :assets, :allow_destroy => true

	belongs_to :sender, :class_name => "User", :foreign_key => :user_id_from
	belongs_to :receiver, :class_name => "User", :foreign_key => :user_id_to

	after_create :set_replied_at

	self.per_page = 15

	def set_replied_at
		self.replied_at = self.created_at
		self.save
	end

	def mark_read(user_id)
		self.read = true
		self.replied_messages.where("user_id_to = ?", user_id).update_all :read => true
		self.save
	end

	def tag
		_map!(read_attribute(:tag))
	end

	def self.send!(to, opts = {})

		# Return false if a subject and body were not provided
		return false if opts[:subject].nil? || opts[:body].nil?

		# Make sure user is a user model
		to = User.find(to) unless to.is_a?(User)

		# Get from value from user.current unless one was specified
		from = User.current if opts[:from].nil?

		# Get from value from the opts array
		unless opts[:from].nil?
			from = User.find(opts[:from]) unless opts[:from].is_a?(User)
			from = opts[:from] if opts[:from].is_a?(User)
		end

		# Get subject and body
		subject = opts[:subject]
		body = opts[:body]

		# Allow setting if the message was read by default
		read = opts[:read] unless opts[:read].nil?
		read = false if opts[:read].nil?

		# Tag the message with an object
		tag = opts[:tag] unless opts[:tag].nil?

		# Create the message
		msg = new
		msg.user_id_to = to.id
		msg.user_id_from = from.id
		msg.subject = subject
		msg.body = body
		msg.read = read
		msg.tag = tag

		if msg.save

			# Notify the user of the message via email
			UserMailer.message_notification(
				msg.user_id_to,
				msg.subject,
				msg.body,
				msg.id,
				from.name,
				msg.tag).deliver

			# Return true on success
			return true
		else

			# Return false on failure
			return false
		end

	end

	def link(attrs = {})

		# Parse attrs
		_attrs = []; attrs.each do |k, v|
			# Make sure not a symbol
			k = k.to_s if k.is_a?(Symbol)
			next if k == 'href'
			# Add to attrs array
			_attrs << "#{k}=\"#{v}\""
		end; attrs = _attrs.join(' ')

		# Return the link to the profile
		return "<a href=\"#{url}\" #{attrs}>Message: #{subject}</a>".html_safe
	end

	def url
		"/messages/#{id}"
	end

end
