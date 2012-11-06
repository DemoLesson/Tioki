class User_Group < ActiveRecord::Base
	set_table_name "users_groups"

	has_one :group
	has_one :user

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
