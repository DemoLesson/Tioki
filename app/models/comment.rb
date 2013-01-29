class Comment < ActiveRecord::Base
	#START automatically generated acts_as_commentable methods
	acts_as_nested_set :scope => [:commentable_id, :commentable_type]

	validates_presence_of :body
	validates_presence_of :user

	# NOTE: install the acts_as_votable plugin if you
	# want user to vote on the quality of comments.
	#acts_as_voteable

	belongs_to :commentable, :polymorphic => true

	# NOTE: Comments belong to a user
	belongs_to :user

	def user!
		return user unless user.nil?
		User.new
	end

	# Helper class method that allows you to build a comment
	# by passing a commentable object, a user_id, and comment text
	# example in readme
	def self.build_from(obj, user_id, comment)
		c = self.new
		c.commentable_id = obj.id
		c.commentable_type = obj.class.base_class.name
		c.body = comment
		c.user_id = user_id
		c
	end

	#helper method to check if a comment has children
	def has_children?
		self.children.size > 0
	end

	# Helper class method to lookup all comments assigned
	# to all commentable types for a given user.
	scope :find_comments_by_user, lambda { |user|
		where(:user_id => user.id).order('created_at DESC')
	}

	# Helper class method to look up all comments for
	# commentable class name and commentable id.
	scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
		where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
	}

	# Helper class method to look up a commentable object
	# given the commentable class name and id
	def self.find_commentable(commentable_str, commentable_id)
		commentable_str.constantize.find(commentable_id)
	end

	# Does this comment belong to a discussion
	def discussion?
		read_attribute(:commentable_type) == 'Discussion'
	end

	#END automatically generated acts_as_commentable methods

	def owner
		Kernel.const_get(commentable_type).find(commentable_id)
	end

	def link(attrs = {})
		return "N/A" unless discussion?

		# Parse attrs
		_attrs = []; attrs.each do |k, v|
			# Make sure not a symbol
			k = k.to_s if k.is_a?(Symbol)
			next if k == 'href'
			# Add to attrs array
			_attrs << "#{k}=\"#{v}\""
		end; attrs = _attrs.join(' ')

		# Return the link to the profile
		return "<a href=\"#{url}\" #{attrs}>#{ERB::Util.html_escape(self.owner.title)}</a>".html_safe
	end

	def url
		return "N/A" unless discussion?
		"/discussions/#{owner.to_param}#c#{id}"
	end
end
