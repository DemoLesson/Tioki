class Group < ActiveRecord::Base
	has_and_belongs_to_many :user, :join_table => 'users_groups'

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
end
