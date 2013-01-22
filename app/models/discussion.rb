class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user

	has_many :followers, :dependent => :destroy
	has_many :following, :through => :followers, :source => :user

	has_many :discussion_tags, :dependent => :destroy
	has_many :skills, :through => :discussion_tags
	has_many :comments, :as => :commentable, :dependent => :destroy

	# Callbacks
	before_destroy :before_destroy
	before_save :before_save

	def self.public

		# At the moment only support group owners for the public check
		query = select('`discussions`.`owner`').where('`discussions`.`owner` LIKE ?', 'Group:%')

		# Remove any discussions that should be shown
		query = query.collect(&:owner).delete_if{|g|g.permissions.public_discussions}.collect(&:tag!)

		# Get everything except the ones we wanted to remove
		where('`discussions`.`owner` NOT IN (?)', query).all
	end

	def before_save
		self.owner = nil if read_attribute(:owner).nil? || read_attribute(:owner).empty?
	end

	def before_destroy
		Notification.where(:notifiable_type => tag!).all.recurse { |n| n.destroy }
		Whiteboard.where(:tag => tag!).all.recurse { |n| n.destroy }
	end

	def to_param
		"#{id}-#{title.parameterize}"
	end

	def participants
		self.comment_threads.collect(&:user).unshift(self.user).uniq
	end

	def following_and_participants
		(self.participants + self.following).uniq
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
		return "<a href=\"#{url}\" #{attrs}>#{ERB::Util.html_escape(self.title)}</a>".html_safe
	end

	def url(add = nil)
		"/discussions/#{self.to_param}" + (add.nil? ? '' : '/' + add)
	end

	def owner

		# Is the owner set already?
		_owner = read_attribute(:owner)
		return nil if _owner.nil?

		# Get the actual owning object
		_class, _id = read_attribute(:owner).split(':')
		_class.constantize.find(_id)
	end

	def owner!
		read_attribute(:owner)
	end
end
