class Group < ActiveRecord::Base

	has_and_belongs_to_many :users, :join_table => 'users_groups'

	has_attached_file :picture,
		:storage => :s3,
		:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
		:content_type => [ 'image/jpeg', 'image/png' ],
		:s3_credentials => Rails.root.to_s + "/config/s3.yml",
		:s3_host_alias => 'tioki.s3.amazonaws.com',
		:url => ':s3_alias_url',
		:path => 'groups/:style/:basename.:extension',
		:bucket => 'tioki',
		:processors => [:thumbnail, :timestamper],
		:date_format => "%Y%m%d%H%M%S"

	def to_param
		"#{id}-#{name.parameterize}"
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

	def permissions
		super.to_switch(APP_CONFIG['bitswitches']['group_permissions'])
	end

	def user_permissions(conds = {})
		user = User.find(conds[:user]) unless conds[:user].nil?
		user = User.current if conds[:user].nil? && !User.current.nil?

		return false if user.nil?

		return User_Group.where('`users_groups`.`user_id` = ? && `users_groups`.`group_id` = ?', user.id, self.id).first.permissions
	end
end
