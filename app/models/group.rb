class Group < ActiveRecord::Base

	def to_param
		"#{id}-#{name.parameterize}"
	end

	# Instantiate BitSwitch
	bitswitch :permissions, APP_CONFIG['bitswitches']['group_permissions']

	# Social KVPair
	kvpair :social
	kvpair :location
	kvpair :contact
	kvpair :misc

	# Connected to users through users_groups
	has_and_belongs_to_many :users, :join_table => 'users_groups'
	
	# Discussions stuff

		def discussions
			Discussion.where(:owner => "#{self.class}:#{self.id}")
		end
	
	# Picture Support
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
			:path => 'groups/:style/' + (Rails.env == 'development' ? 'dev-' : '') + ':basename.:extension',
			:processors => [:thumbnail, :timestamper],
			:date_format => "%Y%m%d%H%M%S"

		def picture_from_url(url)
    		self.picture = download_remote_file(url)
  		end

	# User permissions

		def member?
			return false if User.current.nil?
			return false if User_Group.where('`users_groups`.`user_id` = ? && `users_groups`.`group_id` = ?', User.current.id, self.id).first.nil?
			return true
		end

		def user_permissions(conds = {})
			user = User.find(conds[:user]) unless conds[:user].nil?
			user = User.current if conds[:user].nil? && !User.current.nil?

			# Empty switch
			switchConf = APP_CONFIG['bitswitches']['user_group_permissions']
			return BitSwitch.new(0, switchConf) if user.nil?

			# Get UserGroup record
			user_group = User_Group.where('`users_groups`.`user_id` = ? && `users_groups`.`group_id` = ?', user.id, self.id).first

			# Return false if not a member
			return BitSwitch.new(0, switchConf) if user_group.nil?

			# Unless we want to update the permissions
			return user_group.permissions unless conds[:update].is_a?(Hash)
			
			# Merge permissions
			user_group.permissions = conds[:update]

			# Return permissions
			return user_group.permissions
		end

		def self.my_permissions(type = nil)
			bit = APP_CONFIG['bitswitches']['user_group_permissions'].invert[type.to_s]
			return where("POW(2, ?) & `users_groups`.`permissions` > 0", bit)
		end

		def users(type = nil)
			_users = User.joins("INNER JOIN `users_groups` ON `users`.`id` = `users_groups`.`user_id`").where("`users_groups`.`group_id` = ?", self.id)

			unless type.nil?
				bit = APP_CONFIG['bitswitches']['user_group_permissions'].invert[type]
				return _users.where("POW(2, ?) & `users_groups`.`permissions` > 0", bit)
			end

			return _users
		end

	# Adding in organization support

		has_many :jobs
		has_many :job_packs

		def type?
			organization? ? 'Organization' : 'Group'
		end

		def organization?
			permissions['organization']
		end

		def self.organization
			permissions(:organization => true)
		end

		def self.organization!
			permissions(:organization => false)
		end

		def job_allowance
			allowance = 0

			# Loop through the purchased jobs
			job_packs.each do |jp|
				allowance += jp.jobs
			end

			# Return the allowed amount of jobs
			return allowance
		end

	# Private Methods

		private
  
			def download_remote_file(url)
				io = open(url)
			    
				def io.original_filename
					base_uri.path.split('/').last
				end
			    
				io.original_filename.blank? ? nil : io
			end

end
