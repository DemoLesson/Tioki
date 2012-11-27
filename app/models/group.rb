class Group < ActiveRecord::Base
	acts_as_commentable

	has_and_belongs_to_many :users, :join_table => 'users_groups'

	has_attached_file :picture,
		:storage => :fog,
		:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
		:content_type => [ 'image/jpeg', 'image/png' ],
		:fog_credentials => {
			:provider => 'AWS',
			:aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
			:aws_secret_access_key  => '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',
			:region => 'us-west-2'
		},
		:fog_public => true,
		:fog_directory => 'tioki',
		:path => 'groups/:style/:basename.:extension',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"

	def to_param
		"#{id}-#{name.parameterize}"
	end

	def get_comments
		self.root_comments
	end

	# Create a Comment
	def create_comment(body)
		Comment.build_from(self, User.current.id, body)
	end

	def self.permissions(conds = {})

		# Get available bits and list of conditions
		bits = APP_CONFIG['bitswitches']['group_permissions'].invert
		conditions = Array.new

		# Run bitwise conditions
		conds[:slugs].each do |slug, tf|
			tf = tf > 0 if tf.is_a?(Fixnum); slug = slug.to_s if slug.is_a?(Symbol)
			conditions << "POW(2, #{bits[slug]}) & `groups`.`permissions`" + (tf ? ' > 0' : ' <= 0')
		end

		# Add conditions
		return where(conditions.join(' ' + (conds[:type].nil? ? '&&' : conds[:type]) + ' '))
	end

	def permissions!
		perms = self.permissions unless self.permissions.nil?
		perms = 0 if self.permissions.nil?

		perms.to_switch(APP_CONFIG['bitswitches']['group_permissions'])
	end

	def user_permissions(conds = {})
		user = User.find(conds[:user]) unless conds[:user].nil?
		user = User.current if conds[:user].nil? && !User.current.nil?

		return false if user.nil?

		return User_Group.where('`users_groups`.`user_id` = ? && `users_groups`.`group_id` = ?', user.id, self.id).first.permissions!
	end

	def users(type = nil)
		_users = User.joins("INNER JOIN `users_groups` ON `users`.`id` = `users_groups`.`user_id`").where("`users_groups`.`group_id` = ?", self.id)

		unless type.nil?
			bit = APP_CONFIG['bitswitches']['user_group_permissions'].invert[type]
			return _users.where("POW(2, ?) & `users_groups`.`permissions` > 0", bit)
		end

		return _users
	end
end
