require 'digest/sha1'

class User < ActiveRecord::Base
	geocoded_by :location
	after_validation :geocode, :reverse_geocode, :if => :location_changed?

	#scope to get empty relation
	scope :none, where("1 = 0")
	scope :admin, where(:is_admin => true)
	scope :fake, where(:fake => true)
	scope :all, unscoped

	def reverse_geocode
		#instead of reverse geocoding by coordinates
		#Reverse by the location string
		address = Geocoder.search(self.location)

		if geo = address.first
			self.city = geo.city
			self.state = geo.state
			self.country = geo.country
		end
	end

	## User searchable
	## Solr searchable template
	#searchable do
	#	text :name, :first_name, :last_name, :email, :slug
	#
	#	time :last_login
	#	time :created_at
	#	time :updated_at
	#
	#	integer :login_count
	#	integer :connections_count
	#	integer :privacy_public
	#	integer :privacy_connected
	#	integer :privacy_recruiter
	#
	#	boolean :fake
	#	boolean :is_admin
	#
	#	# For location search
	#	# @todo Not available until SunSpot 2
	#	#latlon :location do
	#	#	Sunspot::Util::Coordinates.new latitude, longitude
	#	#end
	#end

	# Key Value Pairs
	kvpair :social
	kvpair :contact
	kvpair :seeking
	kvpair :authorizations
	kvpair :social_actions
	kvpair :cache

	# Serialized data
	serialize :notification_intervals, Hash

	# BitSwitches
	bitswitch :privacy_public, APP_CONFIG['bitswitches']['user_privacy']
	bitswitch :privacy_connected, APP_CONFIG['bitswitches']['user_privacy']
	bitswitch :privacy_recruiter, APP_CONFIG['bitswitches']['user_privacy']
	bitswitch :email_permissions, APP_CONFIG['bitswitches']['email_permissions']

	# Attribute Access
	attr_protected :id, :salt, :is_admin
	attr_accessor :password, :password_confirmation
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
	attr_accessible :first_name, :last_name, :email, :password, :password_confirmation,
					:avatar, :crop_x, :crop_y, :crop_w, :crop_h, :email_permissions,
					:location, :headline, :occupation, :years_teaching, :job_seeking

	# Has One Connections
	has_one :login_token
	has_one :teacher

	#User occupation constant
	OCCUPATION = [ "Teacher", "Professor", "Administrator", "Student", "Entrepreneur", "Staff", "Other" ]

	# Migrated from teacher.rb
	has_many :applications
	has_many :videos, :dependent => :destroy
	has_many :interviews
	has_many :awards, :dependent => :destroy
	has_many :presentations, :dependent => :destroy
	has_many :experiences, :dependent => :destroy, :order => 'startYear DESC'
	has_and_belongs_to_many :credentials
	has_many :educations, :dependent => :destroy, :order => 'current DESC, year DESC, start_year DESC'
	has_many :assets, :as => :owner,:dependent => :destroy
	has_and_belongs_to_many :subjects
	has_and_belongs_to_many :grades
	validates_associated :assets

	# possible race condition, if two users are signing up at the same time
	# after the creation of first bit before the commit of slug the second user 
	# will fail the validation due as both wslug will be empty
	validates_uniqueness_of :slug, :message => "That profile url is not available"
	validates_presence_of :slug, :on => :update

	# Has Many Connections
	has_many :activities, :order => 'created_at DESC'
	has_many :administered_schools, :through => :school_administrators, :source => :school
	has_many :analytics
	has_many :connection_invites
	has_many :connection_invites, :dependent => :destroy
	has_many :connections, :dependent => :destroy
	has_many :discussions
	has_many :events
	has_many :events_rsvps
	has_many :favorites
	has_many :followed_discussions, :through => :followers, :source => :discussion
	has_many :followers
	has_many :inverse_connections, :class_name => 'Connection', :foreign_key => 'user_id', :dependent => :destroy
	has_many :managed_users, :through => :owners, :source => :owner
	has_many :notifications
	has_many :owners, :class_name => 'SharedUsers', :foreign_key => :user_id, :dependent => :destroy
	has_many :pending_connections, :class_name => 'Connection', :foreign_key => 'user_id', :conditions => 'pending = true', :dependent => :destroy
	has_many :pins
	has_many :reverse_owners, :class_name => 'SharedUsers', :foreign_key => :owned_by, :dependent => :destroy
	has_many :school_administrators, :dependent => :destroy
	has_many :skill_claims, :dependent => :destroy
	has_many :skill_group_descriptions, :dependent => :destroy
	has_many :skill_groups, :through => :skill_claims, :uniq => true
	has_many :skills, :through => :skill_claims
	has_many :technologies, :through => :technology_users
	has_many :technology_users, :dependent => :destroy
	has_many :vouched_skilled_groups
	has_many :vouched_skills, :dependent => :destroy
	has_many :whiteboards

	# Many to Many Connections
	has_and_belongs_to_many :groups, :join_table => 'users_groups'
	has_and_belongs_to_many :whiteboard_hidden, :class_name => 'Whiteboard', :join_table => 'whiteboards_hidden'
	has_and_belongs_to_many :rsvp, :class_name => 'Event', :join_table => 'events_rsvps'

	# Handle avatar uploads to S3
	has_attached_file :avatar,
					  :storage => :fog,
					  :styles => {:medium => "201x201>", :thumb => "100x100", :tiny => "45x45"},
					  :content_type => ['image/jpeg', 'image/png'],
					  :fog_credentials => {
						  :provider => 'AWS',
						  :aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
						  :aws_secret_access_key => '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',
						  :region => 'us-west-2'
					  },
					  :fog_public => true,
					  :fog_directory => 'tioki',
					  :path => 'avatars/:style/:basename.:extension',
					  :processors => [:thumbnail, :timestamper],
					  :date_format => "%Y%m%d%H%M%S"

	# Validate that the image uplaoded was indeed an image
	validates_attachment_content_type :avatar, :content_type => [/^image\/(?:jpeg|gif|png)$/, nil], :message => 'Uploading picture failed.'

	# Validations
	validates_length_of :password, :within => 5..40, :on => :create
	validates_length_of :password, :within => 5..40, :on => :update, :unless => lambda { |user| user.password.blank? }
	validates_confirmation_of :password
	validates_presence_of :first_name
	validates_presence_of :last_name
	validates_uniqueness_of :email
	validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email address."

	# Callbacks in order or processing
	after_create :after_create
	before_save :before_save
	after_find :_isorg

	# Delete all connections associated with the user
	before_destroy :remove_connections

	def remove_connections;
		Connection.mine(:user => self).map(&:destroy)
	end

	def _isorg

		_up = read_attribute(:updated_at)

		# Cache organization value
		organization? if _up.nil? || 1.day.ago > _up
	end

	#after_save :add_ab_test_data

	def after_create
		# Create invite code
		create_invite_code

		# Create guest code
		create_guest_code

		# Create slug for the url
		self.update_attribute(:slug, "#{id}#{first_name}#{last_name}".downcase.parameterize)

		# Add to the Tioki technology
		TechnologyUser.create(:user => self, :technology_id => 15)

		# Send out welcome email
		UserMailer.user_welcome_email(self).deliver
	end

	# Return jobs that I administrate
	def my_jobs
		organizations.map(&:jobs).flatten
	end

	# Return my organizations
	def organizations(rank = :administrator)
		groups.organization.my_permissions(rank)
	end

	def change_password(params)
		@user = User.find(self.id)

		if User.authenticate(self.email, params[:current_password]) == @user
			new_pass = params[:password]
			confirm_pass = params[:confirm_password]

			if new_pass == confirm_pass
				self.password=new_pass
				if self.save
					return "Successfully changed your password."
				else
					return "Could not change your password."
				end
			end
		else
			return "Your current password was incorrect."
		end
	end

	# @todo can we optimize this a bit?
	def cleanup

		# Delete Schools
		# @todo is this still needed? / deprecate?
		@schools = School.where('owned_by = ?', self.id).all
		@schools.each do |school|
			school.remove_associated_data
		end
		@schools.map(&:destroy)

		# Migration
		# Delete Teachers
		#@teachers = Teacher.find(:all, :conditions => ['user_id = ?', self.id])
		#@teachers.map(&:destroy)

		# Delete Shared Users
		# @todo is this still needed? / deprecate?
		@sharedusers = SharedUsers.where('user_id = ?', self.id).all
		@sharedusers.map(&:destroy)

		# Delete Shared Schools
		# @todo is this still needed? / deprecate?
		@sharedschools = SharedSchool.where('user_id = ?', self.id).all
		@sharedschools.map(&:destroy)

		# Delete all Connections
		@connections = Connection.mine(:user => self.id)
		@connections.map(&:destroy)
	end

	def completion
		#headline
		percent = 0
		percent += 10 if self.headline.present?
		percent += 10 if self.social.first
		percent += 10 if self.skills.first
		percent += 10 if self.location.present?
		percent += 10 if self.educations.first
		percent += 5 if self.subjects.first
		percent += 5 if self.grades.first
		percent += 5 if self.occupation.present?
		percent += 5 if !self.job_seeking.nil?
		percent += 10 if self.experiences.first
		percent += 10 if self.avatar?
		percent += 10 if self.videos.first
		return percent
	end
	
	def completion_options
		options = []

		options << "occupation" unless self.occupation.present? && !self.job_seeking.present?
		options << "location" unless self.location.present?
		options << "headline"  unless self.headline.present?
		options << "social" unless self.social.first
		options << "subjects" unless self.subjects.first && self.grades.first
		options << "skills" unless self.skills.first
		options << "education" unless self.educations.first
		options << "experience" unless self.experiences.first
		options << "picture" unless self.avatar?
		options << "video" unless self.videos.first

		return options
	end

	def connections
		Connection.where('`user_id` = ? || `owned_by` = ?', self.id, self.id)
	end

	# @todo optimize and rebuild
	def distance(find, level = 1, delve = false, scanned = [])

		# Dont go to deep
		return nil if level > 3

		# Get the connections of this user
		connections = Connection.mine(:pending => false, :user => self.id)

		# Did we find anything on this level
		found = !connections.where('`owned_by` = ? || `user_id` = ?', find, find).first.nil?

		# If we did find the answer return the level
		return level if found

		# Unless were delving
		return nil unless delve || level == 1

		# Go through the stack
		results = connections.eachX(2, 'break') do |i, user|
			user = user.not_me(self.id)

			# Skip if already scanned
			next if scanned.include? user.id && i == 2

			# Search down a bit deeper
			results = user.distance(find, level + 1, i == 1 ? false : true, scanned)

			# This has been scanned
			scanned << user.id if i == 2

			results
		end

		# Return the results
		unless results.nil?
			results = results.flatten.delete_if { |x| x.nil? }
			return results.min if level == 1
			return results
		end
	end

	def facebook_auth?
		self.authorizations[:facebook_access_token].present?
	end

	def got_started
		start_count = 0

		#3 connections
		if Connection.mine(:pending => false).count >= 5
			start_count += 1
		end

		#follow three discussions
		if Follower.where("user_id = ?", self.id).count >= 3
			start_count += 1
		end

		#Join three groups

		if User_Group.where("user_id = ?", self.id).count >= 3
			start_count += 1
		end

		#Vouch 5 skills
		if VouchedSkill.where("voucher_id = ?", self.id).count >= 5
			start_count += 1
		end

		#post to whiteboard
		if Whiteboard.where("whiteboards.slug = ?", 'share').first
			start_count += 1
		end

		#Post a reply to discussion
		if Comment.where("commentable_type = 'Discussion' && comments.user_id = ?", self.id).first
			start_count += 1
		end

		#require a date fot his one, ccureently there is not avatar_created_at
		#we could create one, but it would be just one more thing to update on avatar creation
		if self.avatar?
			start_count += 1
		end

		if start_count >= 5
			return true
		else
			return false
		end
	end

	def is_admin?
		self.school != nil || self.is_shared == true
	end

	def is_limited?
		self.is_limited
	end

	def jobcount
		jobs=0
		schools=self.schools
		schools.each do |school|
			jobs=school.jobs.count+jobs
		end
		return(jobs)
	end

	def password=(pass)
		@password=pass
		self.salt = User.random_string(10) if !self.salt?
		self.hashed_password = User.encrypt(@password, self.salt)
	end

	def pending_connections(pending = true)
		connections.where('`pending` = ?', pending)
	end

	def pending_count
		Connection.mine(:user => self.id, :pending => true, :creator => false).count
	end

	def rank?(type = false)
		return !nil? unless type
		return !nil? && is_admin if type == 'admin'
	end

	def referrals
		#after donors choose before tioki bucks
		ConnectionInvite.where('`user_id` = ? && created_user_id IS NOT NULL && created_at > ? && created_at < ?', self.id, "2012-10-22 20:00:00", TIOKI_BUCKS_START)
	end

	# @todo is this still needed / deprecate?
	def school
		return(School.where(:owned_by => id).first)
	end

	# @todo is this still needed / deprecate?
	def schools
		if is_shared
			s = SharedUsers.where(:user_id => id).first
			return(School.where(:owned_by => s.owned_by).all)
		else
			return(School.where(:owned_by => id).all)
		end
	end

	def self.authenticate(email, pass)
		user = find(:first, :conditions => ["email = ?", email])

		if user.nil? or User.encrypt(pass, user.salt) != user.hashed_password
			return nil
		end

		user
	end

	def self.avatar?(has = true)
		where('`users`.`avatar_updated_at` IS ' + (has ? 'NOT ' : '') + 'NULL')
	end

	def send_new_password
		new_pass = User.random_string(10)
		self.update_attribute(:password, new_pass)
		self.update_attribute(:password_confirmation, new_pass)
		UserMailer.deliver_forgot_password(self.email, self.name, new_pass).deliver
		#Notifications.deliver_forgot_password(self.email, self.name, new_pass)
	end

	def before_save

		# Name normalization
		if !(self.changed & ['first_name', 'last_name', 'name']).empty?
			# Get the name associated with the user
			if !(self.changed & ['first_name', 'last_name']).empty?
				string = "#{self.first_name} #{self.last_name}".strip.downcase.squeeze(' ')
			elsif self.changed.include?('name')
				string = "#{self.name}".downcase.squeeze(' ')
			end

			# Split on
			splits = ['mc', '\'', '-', ' ']

			# Properly Capitalize
			splits = splits.collect { |x| (0..string.length-1).find_all { |i| string[i, x.length]==x }.collect { |i| i+x.length } }.flatten.uniq.<<(0).sort { |a, b| b<=>a }
			fibers = splits.collect { |x| string.slice!(x..-1) }
			string = fibers.collect { |x| x.capitalize }.reverse.join

			# Set the user name
			self.first_name = (names = string.split(' ')).first
			self.last_name = names.last
			self.name = string
		end

	end

	def name
		return 'Anonymous' if new_record? || !deleted_at.nil?
		read_attribute(:name)
	end

	# @todo deprecate?
	def sharedschool
		if is_limited == true
			school = SharedSchool.where(:user_id => id).first
			return(School.find(school.school_id))
		else
			admin = SharedUsers.where(:user_id => id).first
			return(School.where(:owned_by => admin.owned_by).first)
		end
	end

	# @todo find a cleaner way to do this that does not involve recursively calling collect / deprecate?
	def sharedschools
		schools = SharedSchool.where(:user_id => id).all.collect(&:school_id)
		return(School.find(schools))
	end

	def successful_referrals
		ConnectionInvite.where('`user_id` = ? && created_user_id IS NOT NULL and donors_choose = true and created_at < ?', self.id, "2012-10-22 20:00:00")
	end

	#def teacher
	#	return(Teacher.find(:first, :conditions => {:user_id => id}))
	#end

	def tioki_bucks
		tioki_bucks = 0
		if self.got_started
			tioki_bucks += 5
		end

		if self.teacher.facebook_connect
			tioki_bucks += 1
		end

		if self.teacher.twitter_connect
			tioki_bucks += 1
		end

		if self.teacher.tweet_about
			tioki_bucks += 1
		end

		invite_count = ConnectionInvite.where("user_id = ? && connection_invites.created_at > ?", self.id, TIOKI_BUCKS_START).count

		#two dollars per invite maxed at 42 dollars
		if invite_count*2 > 42
			tioki_bucks += 42
		else
			tioki_bucks += invite_count*2
		end

		return tioki_bucks
	end

	def twitter_auth?
		self.authorizations[:twitter_oauth_token].present? && self.authorizations[:twitter_oauth_secret].present?
	end

	def update_login_count
		puts "logincount update"

		if login_count?
			update_attribute(:login_count, login_count + 1)
		else
			update_attribute(:login_count, 1)
		end

		update_attribute(:last_login, Time.now)
	end

	def update_settings(params)
		@user = User.find(self.id)

		if User.authenticate(@user.email, params[:password]) == @user
			# self.password = params[:password]
			self.email = params[:email]
			self.name = params[:name]
			self.password = self.password_confirmation = params[:password]

			if self.save
				return "Your settings have been updated!"
			else
				return self.errors.full_messages.to_sentence
			end
		else
			return "Your password was incorrect."
		end
	end

	# @todo is the all on the end required
	def vouched_skill_groups
		SkillGroup.joins(:skills => :vouched_skills).where("vouched_skills.user_id = ?", self.id).all
	end

	# Profile URL
	def url(type = :default)
		return '#' if new_record? || !deleted_at.nil?
		"/profile/#{self.slug}" + (type.to_sym == :default ? '' : '/' + type.to_s)
	end

	# Profile Link
	def link(*args)
		return 'Anonymous' if new_record? || !deleted_at.nil?
		raise ArgumentError, 'Expects no more then two args' if args.count > 2

		attrs = {}
		type = :default

		# Get the type and attrs
		args.each do |v|
			if v.is_a?(Hash)
				attrs = v
			else
				type = v
			end
		end

		# Parse attrs
		_attrs = []; attrs.each do |k, v|
			# Make sure not a symbol
			k = k.to_s if k.is_a?(Symbol)
			next if k == 'href'
			# Add to attrs array
			_attrs << "#{k}=\"#{v}\""
		end; attrs = _attrs.join(' ')

		# Return the link to the profile
		return "<a href=\"#{url(type)}\" #{attrs}>#{ERB::Util.html_escape(self.name)}</a>".html_safe
	end

	# Migrated from teacher.rb
	def has_social?
		!self.social.empty?
	end

	# Migrated from teacher.rb
	def me?
		!User.current.nil? && User.current == self
	end

	# Migrated from teacher.rb
	def create_guest_code
		guest_code = rand(36**8).to_s(36)
		self.update_attribute(:guest_code, guest_code)
	end

	# Migrated from teacher.rb
	def video
		# Review
		v = videos.where("featured = true").first
		v = videos.order('`created_at` DESC').first if v.nil?
		return v
	end

	# Get my current job
	def currentJob
		experiences.where(:current => true).first
	end

	def self.search(args = {})

		if args[:email]
			# Only one person can have this email
			return where(:email => args[:email])
		end

		tup = SmartTuple.new(" AND ")
		join_array = Array.new

		if args[:skills]
			tup << SmartTuple.new(" OR ").add_each(args[:skills]) { |skill_id| ["skills.id = ?", skill_id] }
			join_array << :skills
		end

		if args[:subjects]
			tup << SmartTuple.new(" OR ").add_each(args[:subjects]) { |subject_id| ["subjects.id = ?", subject_id] }
			join_array << :subjects
		end

		if args[:grades]
			tup << SmartTuple.new(" OR ").add_each(args[:grades]) { |grade_id| ["grades.id = ?", grade_id] }
			join_array << :grades
		end

		if args[:name]
			args[:name].split.each do |token|
				tup << ["(users.first_name LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?)", "#{token}%", "% #{token}%", "#{token}%"]
			end
		end

		#if args[:school]
		#	args[:school].split.each do |token|
		#		tup << ["experiences.company LIKE ? OR experiences.company LIKE ?", "#{token}%", "% #{token}%"]
		#	end
		#	join_array << :experiences
		#end

		if args[:schools]
			# Will be eact messages
			subtup = SmartTuple.new(" OR ")

			params[:schools].each do |school|
				subtup << ["experiences.company = ?", school]
			end

			tup << subtup

			join_array << :experiences
		end

		if args[:locations]
			#Uses populated populated country, state, city
			#fields as opposed to a geocoder search

			subtup = SmartTuple.new(" OR ")

			params[:locations].each do |token|
				subtup << ["(users.country = ? || users.state = ? || users.city = ?)", token, token, token]
			end

			tup << subtup
		end

		if args[:schools] || args[:skills] || args[:subjects] || args[:grades]
			query = joins(join_array).where(tup.compile)
		else
			query = where(tup.compile)
		end

		#only search on one location at a time currently
		if args[:location]
			#Get the bounds in which this location is contained
			address = Geocoder::search(args[:location]).first

			if address
				if address.geometry.bounds
					coords = address.geometry.bounds.values.collect { |coord| [coord.lat, coord.lng] }
				else
					#Some things do not have a bounding box given by google
					coords = address.geometry.viewport.values.collect { |coord| [coord.lat, coord.lng] }
				end

				#get distance for bounding box
				distance = Geocoder::Calculations.distance_between(coords.first, coords.last)

				box = Geocoder::Calculations.bounding_box(address.geometry.location.values, distance)
				return query.within_bounding_box(box)
			else
				return self.none
			end

		else
			return query.select("DISTINCT(users.id), users.*")
		end
	end

	def new_asset_attributes=(asset_attributes)
		assets.build(asset_attributes)
	end

	def save_assets
		assets.each do |asset|
			asset.save
		end
	end

	def snippet_watchvideo_button
		@video = Video.where('user_id = ? AND is_snippet=?', self.id, true).order('created_at DESC').first
		if @video != nil
			embedstring= "<a rel=\"shadowbox;width=;height=480;player=iframe\" href=\"/videos/#{@video.id}\" class='button'>Watch Snippet</a>"

			begin
				if @video.encoded_state == 'queued'
					Zencoder.api_key = 'ebbcf62dc3d33b40a9ac99e623328583'
					@status = Zencoder::Job.progress(@video.job_id)
					if @status.body['outputs'][0]['state'] == 'finished'
						@video.encoded_state = 'finished'
						@video.save
						return embedstring
					else
						return ""
					end
				else
					return embedstring
				end
			rescue
				return ""
			end
		else
			return ""
		end
	end

	def current_job_string
		if (current_job = self.experiences(:current => true).first)
			return [current_job.position, current_job.company].delete_if { |x| x.empty? }.join(' at ')
		else
			return ""
		end
	end

	def organization?
		isorg = self.groups.my_permissions(:administrator).organization.count > 0
		self.cache = {'organization' => isorg ? 'true' : nil} #if updated_at < 1.day.ago
		return isorg
	end

	def self.organization?
		cache(:organization => 'true')
	end

	def submitted_application?
		self.applications.where("applications.submitted = 1").count > 0
	end

	def application_for(user)
		job_ids = self.applications.collect(&:job_id)
		user.my_jobs.collect(&:id).any? { |job_id| job_ids.include? job_id }
	end

	# Connections

	def connected_to?(_user)
		not connection_to(_user).nil?
	end

	def connection_to(_user, pending = false)
		Connection.mine(:user => self, :pending => pending).where('`owned_by` = ? || `user_id` = ?', _user.id, _user.id).first
	end

	# Permissions

	# Can resource be created
	def can_create?(resource)
		return true unless resource.respond_to?('can_be_created_by?')
		resource.can_be_created_by?(self)
	end

	# Can resource be created
	def can_update?(resource)
		return true unless resource.respond_to?('can_be_updated_by?')
		resource.can_be_updated_by?(self)
	end

	# Can resource be created
	def can_destroy?(resource)
		return true unless resource.respond_to?('can_be_destroyed_by?')
		resource.can_be_destroyed_by?(self)
	end

	def can_be_created_by?(_user)
		return true if _user.new_record?
		return true if _user.is_admin
		false
	end

	def can_be_destroyed_by?(_user)
		return false if _user.new_record?
		return true if _user.is_admin

		self == _user
	end

	def can_be_updated_by?(_user)
		return false if _user.new_record?
		return true if _user.is_admin

		self == _user
	end


	protected

	def create_invite_code
		user_invite = nil
		generated_code = rand(36**7).to_s(36)
		begin
			user_invite = User.where(:invite_code => generated_code).first
		end while user_invite != nil
		self.update_attribute(:invite_code, generated_code)
	end

	def self.current
		User.find(session[:user]) unless session[:user].nil?
	end

	def self.encrypt(pass, salt)
		Digest::SHA1.hexdigest(pass+salt)
	end

	def self.random_string(len)
		#generate a random password consisting of strings and digits
		chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
		newpass = String.new
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end

	private

	def add_ab_test_data

		# If the user id is even then apple the B ab test
		update_attribute(:ab, 'B') if id.even?
		update_attribute(:ab, 'A') unless id.even?
	end
end
 
