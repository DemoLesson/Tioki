class Group < ActiveRecord::Base
	def to_param
		"#{id}-#{name.parameterize}"
	end

	# Instantiate BitSwitch
	bitswitch :permissions, APP_CONFIG['bitswitches']['group_permissions']

	# Social KVPair
	kvpair :contact
	kvpair :misc

	store :location
	store :social

	after_validation :geocode
	geocoded_by :address

	def address
		[self.location[:address], self.location[:city], self.location[:region], self.location[:postal]].compact.join(', ')
	end

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
			:path => 'groups/:style/:basename.:extension',
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
				bit = APP_CONFIG['bitswitches']['user_group_permissions'].invert[type.to_s]
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

		# Returns the job allowance for the group
		# Author: Kelly Lauren Summer Becker
		def job_allowance

			# 100% SQL based aggregation
			job_packs.jobAllowance.first.jobs rescue 0
		end

		# Returns the still active jobs based on job packs
		# Author: Kelly Lauren Summer Becker
		def ajobs

			# 100% SQL based aggregation and remove expired
			job_packs.jobAllowance.disableExpired
		end

		def url
			"groups/#{self.to_param}"
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
			return "<a href=\"/group/#{self.id}\" #{attrs}>#{ERB::Util.html_escape(self.name)}</a>".html_safe
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
