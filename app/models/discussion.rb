class Discussion < ActiveRecord::Base
	acts_as_commentable

	belongs_to :user

	has_many :followers, :dependent => :destroy
	has_many :following, :through => :followers, :source => :user
	
	has_many :discussion_tags, :dependent => :destroy
	has_many :skills, :through => :discussion_tags

	# Cleanup everything
	before_destroy :cleanup!

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
		_attrs = []; attrs.each do |k,v|
			# Make sure not a symbol
			k = k.to_s if k.is_a?(Symbol)
			next if k == 'href'
			# Add to attrs array
			_attrs << "#{k}=\"#{v}\""
		end; attrs = _attrs.join(' ')

		# Return the link to the profile
		return "<a href=\"/discussions/#{self.id}\" #{attrs}>#{self.title}</a>".html_safe
	end

	def cleanup!
		Notification.where(:notifiable_type => tag!).all.recurse{|n| n.destroy}
	end
end
