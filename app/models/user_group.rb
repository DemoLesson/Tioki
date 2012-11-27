class User_Group < ActiveRecord::Base
	set_table_name "users_groups"

	# Instantiate BitSwitch
	bitswitch :permissions, APP_CONFIG['bitswitches']['user_group_permissions']

	belongs_to :group
	belongs_to :user
end
