class User_Group < ActiveRecord::Base
	set_table_name "users_groups"

	belongs_to :group
	belongs_to :user

	scope :permissions, lambda { |type| 
		dump type
		unless type.nil?
			# Get the bit based on the configuration and return matching the bit
			bit = APP_CONFIG['bitswitches']['group_permissions'].invert[type]
			return "POW(2, #{bit}) & `users_groups`.`permissions` > 0"
		end
	}

	def self.permissions(conds = {})

		# Get available bits and list of conditions
		bits = APP_CONFIG['bitswitches']['user_group_permissions'].invert
		conditions = Array.new

		# Run bitwise conditions
		conds[:slugs].each do |slug, tf|
			tf = tf > 0 if tf.is_a?(Fixnum); slug = slug.to_s if slug.is_a?(Symbol)
			conditions << "POW(2, #{bits[slug]}) & `users_groups`.`permissions`" + (tf ? ' > 0' : ' <= 0')
		end

		# Add conditions
		return where(conditions.join(' ' + (conds[:type].nil? ? '&&' : conds[:type]) + ' '))
	end

	def permissions!
		perms = self.permissions unless self.permissions.nil?
		perms = 0 if self.permissions.nil?

		perms.to_switch(APP_CONFIG['bitswitches']['user_group_permissions'])
	end
end
