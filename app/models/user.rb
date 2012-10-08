require 'digest/sha1'

class User < ActiveRecord::Base
	validates_length_of :password, :within => 5..40
	#validates_presence_of :email, :password, :password_confirmation
	validates_confirmation_of :password
	validates_presence_of :first_name
	validates_presence_of :last_name
	validates_uniqueness_of :email
	validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email address."  

	has_many :school_administrators, :dependent => :destroy
	has_many :administered_schools, :through => :school_administrators, :source => :school

	has_many :activities, :order => 'created_at DESC'
	has_many :pins

	has_many :skill_claims, :dependent => :destroy
	has_many :skills, :through => :skill_claims

	has_many :skill_groups, :through => :skill_claims, :uniq => true
	has_many :skill_group_descriptions, :dependent => :destroy
	has_many :connection_invites, :dependent => :destroy

	# Connecting to events
	has_many :events

	# Connect to analytic events
	has_many :analytics

	# Connect to whiteboard events
	has_many :whiteboards
	has_and_belongs_to_many :whiteboard_hidden, :class_name => 'Whiteboard', :join_table => 'whiteboards_hidden'
	
	has_many :owners, :class_name => 'SharedUsers', :foreign_key => :user_id, :dependent => :destroy
	has_many :reverse_owners, :class_name => 'SharedUsers', :foreign_key => :owned_by, :dependent => :destroy

        #users created through their referrals
        has_many :connection_invites

	has_many :managed_users, :through => :owners, :source => :owner

	has_many :vouched_skills, :dependent => :destroy
	has_many :vouched_skilled_groups
	
	attr_protected :id, :salt, :is_admin, :verified
	attr_accessor :password, :password_confirmation
	attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
	attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :avatar, :crop_x, :crop_y, :crop_w, :crop_h #, :login_count, :last_login

	before_create :set_full_name
	after_create :send_verification_email

	has_one :teacher
	has_many :videos, :through => :teacher
	has_many :applications, :through => :teacher
	has_many :connections, :foreign_key => "owned_by", :dependent => :destroy
	has_many :inverse_connections, :class_name => "Connection", :foreign_key => "user_id", :dependent => :destroy
	has_many(:pending_connections,
					 :class_name => 'Connection',
					 :foreign_key => "user_id",
					 :conditions => "pending = true",
					 :dependent => :destroy)
	
	has_one :login_token

	# Event RSVPs (This might look a bit weird)
	has_and_belongs_to_many :rsvp, :class_name => 'Event', :join_table => 'events_rsvps'
	has_many :events_rsvps
	
	has_attached_file :avatar,
										:storage => :s3,
										:styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
										:content_type => [ 'image/jpeg', 'image/png' ],
										:s3_credentials => Rails.root.to_s + "/config/s3.yml",
										:url  => '/avatars/:style/:basename.:extension',
										:path => 'avatars/:style/:basename.:extension',
										:bucket => 'DemoLessonS3',
										:processors => [:thumbnail, :timestamper],
										:date_format => "%Y%m%d%H%M%S"
	
	#validates_attachment_presence :avatar
	validates_attachment_content_type :avatar, :content_type => [/^image\/(?:jpeg|gif|png)$/, nil], :message => 'Uploading picture failed.'  
	# WARNING                                 
	#validates_attachment_size :avatar, :less_than => 2.megabytes,
	#                                   :message => 'Picture was too large, try scaling it down.'


	#soft deletion
	default_scope where(:deleted_at => nil)

	def vouched_skill_groups
		SkillGroup.joins(:skills => :vouched_skills).find(:all, :conditions => ["vouched_skills.user_id = ?",self.id])
	end

	def pending_count
		Connection.mine(:user => self.id, :pending => true, :creator => false).count
	end

	def pending_connections(pending = true)
		connections.where('`pending` = ?', pending)
	end

	def connections
		Connection.where('`user_id` = ? || `owned_by` = ?', self.id, self.id)
	end

	def is_admin?
		self.school != nil || self.is_shared == true
	end

	def is_limited?
		self.is_limited
	end

	def all_schools
		if self.is_limited?
			return self.sharedschools
		else
			return self.schools
		end
	end

	def all_jobs_for_schools
		all_schools.each.inject([]) do |jobs, school|
			jobs += Job.find(:all,
											 :conditions => ['school_id = ? AND active = ?', school.id, true],
											 :order => 'created_at DESC')
		end
	end
	
	def create_teacher
		# Set the teacher to a shorter variable
		t = self.teacher

		# If there is already a teacher model connected
		# then don't create a new teacher
		if t.nil?

			# Crate a new teacher
			t = Teacher.new(:user => self)

			# Link up the current user
			t.user_id = self.id

			# Generate a guest pass
			t.create_guest_pass

			#generate an invite code
			self.create_invite_code

			# Generate a profile url
			url = Random.rand(10..99).to_s + self.id.to_s + self.name

			# Remove any spaces in the URL
			url = url.gsub(/[ .?&:=+]/, '')

			# Downcase the URL
			t.url = url.downcase

			# Save it
			t.save!
		end

		# Return
		return t

		# Nothing from here to "end" is being run
		@mailer = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'mailer.yml'))).result)[Rails.env]
		@message = Message.new
		@message.user_id_from = @mailer["from"].to_i
		@message.user_id_to = self.id
		@message.subject = @mailer["subject"]
		@message.body = "Hi "+self.name+","+@mailer["message"]+"Brian Martinez"
		@message.read = false
		@message.save
	end
	
	# def create_additional_school
	#     s = School.create!(:user => self, :map_address => '100 West 1st Street', :map_city => 'Los Angeles', :map_state => 5, :map_zip => '90012', :name => 'New School', :gmaps => 1)
	#     s.owned_by = self.id
	#     s.save!
	#     return s
	#   end

	def create_school
		s = self.school
		if s.nil?
			s = School.create!(:user => self, :map_address => '100 W 1st St', :map_city => 'Los Angeles', :map_state => 5, :map_zip => '90012', :name => 'New School', :gmaps => 1)
			s.owned_by = self.id
			s.save!
		end
		return s
		@mailer = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'mailer_schools.yml'))).result)[Rails.env]
		@message = Message.new
		@message.user_id_from = @mailer["from"].to_i
		@message.user_id_to = self.id
		@message.subject = @mailer["subject"]
		@message.body = "Hi "+self.name+","+@mailer["message"]+"Brian Martinez"
		@message.read = false
		@message.activify
		@message.save
	end

	def teacher
		return(Teacher.find(:first, :conditions => {:user_id => id}))
	end

	def school
		return(School.find(:first, :conditions => {:owned_by => id}))
	end

	def job_allowance
		if is_shared
			@shared= SharedUsers.find(:first, :conditions => { :user_id => id})
			o=Organization.find(:first, :conditions => { :owned_by => @shared.owned_by})
			return(o.job_allowance)
		else
			o=Organization.find(:first, :conditions => { :owned_by => id})
			return(o.job_allowance)
		end
	end
	
	def schools
		if is_shared
			s=SharedUsers.find(:first, :conditions => {:user_id => id})
			return(School.find(:all, :conditions => {:owned_by => s.owned_by}))
		else
			return(School.find(:all, :conditions => {:owned_by => id}))
		end
	end

	def jobcount
		jobs=0
		schools=self.schools
		schools.each do |school|
			jobs=school.jobs.count+jobs
		end
		return(jobs)
	end
	
	def sharedschool
		if is_limited == true
			school = SharedSchool.find(:first, :conditions => { :user_id => id } )
			return(School.find(school.school_id))
		else
			admin= SharedUsers.find(:first, :conditions => { :user_id => id})
			return(School.find(:first, :conditions => {:owned_by => admin.owned_by}))
		end
	end

	def sharedschools
		schools = SharedSchool.find(:all, :conditions => { :user_id => id }).collect(&:school_id)
		return(School.find(schools))
	end

	def organization
		if is_shared
			s=SharedUsers.find(:first, :conditions => { :user_id => id })
			return(Organization.find(:first, :conditions => { :owned_by => s.owned_by }))
		else
			return(Organization.find(:first, :conditions => { :owned_by => id }))
		end
	end

	def self.authenticate(email, pass)
		user = find(:first, :conditions=>["email = ?", email])

		if user.nil? or User.encrypt(pass, user.salt) != user.hashed_password
			return nil
		end

		# Set the current user to model
		self.current = user

		user
	end
	
	def update_login_count
		puts "logincount update"
		
		u=User.find(self.id)
		if u.login_count?
			u.login_count = u.login_count+1
		else
			u.login_count = 1
		end
		u.update_attribute(:last_login, Time.now)
	end
	
	def send_verification_email
		self.verification_code = User.random_string(10)
			self.save!
			#Notifications.deliver_verification(self.id, self.name, self.verification_code)
	end
	
	def self.verify!(user_id, verification_code)
		u=find(user_id)
		if (u.present? && u.verification_code == verification_code)
			u.is_verified = true
			u.save!(false)
		else
			raise "verification code does not match email or unregistered email"
		end
	end
		
	def password=(pass)
		@password=pass
		self.salt = User.random_string(10) if !self.salt?
		self.hashed_password = User.encrypt(@password, self.salt)
	end

	def send_new_password
		new_pass = User.random_string(10)
		self.update_attribute(:password, new_pass)
		self.update_attribute(:password_confirmation, new_pass)
		UserMailer.deliver_forgot_password(self.email, self.name, new_pass).deliver
		#Notifications.deliver_forgot_password(self.email, self.name, new_pass)
	end

	def set_full_name
		logger.debug "!!! SET FULL NAME !!!"
		self.name = "#{first_name} #{last_name}"
	end
	
	def update_settings(params)
		@user = User.find(self.id)
	
		if User.authenticate(@user.email, params[:password]) == @user
			# self.password = params[:password]
			self.email = params[:email]
			self.name = params[:name]
			self.password = self.password_confirmation = params[:password]
			
			#if self.update_attributes(:email => params[:email], :name => params[:name], :password => params[:password])
			if self.save!
				return "Your settings have been updated!"
			else
				return "Could not update your settings."
			end
		else
			return "Your password was incorrect."
		end
	end

	def successful_referrals
		ConnectionInvite.where('`user_id` = ? && created_user_id IS NOT NULL and donors_choose = true', self.id)
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

	def privacy
		super.to_switch(APP_CONFIG['bitswitches']['user_privacy'])
	end

	def cleanup
		@schools = School.find(:all, :conditions => ['owned_by = ?', self.id])
		@schools.each do |school|
			school.remove_associated_data
		end
		@schools.map(&:destroy)
		@teachers = Teacher.find(:all, :conditions => ['user_id = ?', self.id])
		@teachers.map(&:destroy)
		@sharedusers = SharedUsers.find(:all, :conditions => ['user_id = ?', self.id])
		@sharedusers.map(&:destroy)
		@sharedschools = SharedSchool.find(:all,:conditions => ['user_id = ?', self.id])
		@sharedschools.map(&:destroy)
		@applications = Application.find(:all, :conditions => ['teacher_id = ?', self.id])
		@connections = Connection.mine(:user => self.id)
		@connections.map(&:destroy)
		@applications.each do |application|
			@activities = Activity.find(:all, :conditions => ['application_id = ?', application.id])
			@activities.map(&:destroy)
		end
		@applications.map(&:destroy)
	end

	# Get user percent completion
	def completion

		# Only update progress if the model is over a day old or empty
		if self.updated_at < Time.new.yesterday || super.nil? || super == 0
			percent = 0

			if !self.teacher.nil?
				percent += 5 if self.teacher.headline.present?
				percent += 15 if self.connections.count >= 5
				percent += 5 if self.teacher.has_social?
				percent += 10 if !self.teacher.educations.empty?
				percent += 10 if !self.teacher.experiences.empty?
				percent += 5 if !self.teacher.credentials.empty?
				percent += 5 if self.avatar?
				percent += 10 if self.skills.count >= 5

				# Tech tags
				percent += 10 if true

				percent += 15 if self.vouched_skills.count > 3
				percent += 10 if self.teacher.videos.count > 0
			elsif !self.school.nil?
				percent = 100
			end

			# Save the user with the updated completion
			self.update_attribute(:completion, percent)
		else
			percent = super
		end

		return percent
	end

	protected

		def self.encrypt(pass, salt)
			Digest::SHA1.hexdigest(pass+salt)
		end

		def self.random_string(len)
			#generate a random password consisting of strings and digits
			chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
			newpass = ""
			1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
			return newpass
		end

		def create_invite_code
			user_invite = nil
			generated_code = rand(36**7).to_s(36)
			begin
				user_invite = User.find(:first, :conditions => ['invite_code = ?', generated_code])
			end while user_invite != nil
			self.update_attribute(:invite_code,  generated_code)
		end

		# Store the currently active user for access
		def self.current
			@user
		end

		def self.current=(user)
			@user = user
		end
end
 
