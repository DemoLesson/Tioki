class UserMailer < ActionMailer::Base
	default :from => "Tioki <tioki@tioki.com>"

	def user_welcome_email(user_id)
		@user = User.find(user_id)

		mail = mail(:to => @user.email, :subject => 'Welcome to Tioki!')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('user_welcome_email')
		end

		return mail
	end

	def teacher_welcome_email_temppassword(user_id, password)
		@user = User.find(user_id)
		@password = password

		mail = mail(:to => @user.email, :subject => 'Welcome to Tioki!')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('teacher_welcome_email_temppassword')
		end

		return mail
	end

	def message_notification(user_id, subject, body, id, name, tag = nil)
		@user = User.find(user_id)
		@subject = subject
		@message_body = body[0,140]
		@id = id
		@sender_name = name

		if tag
			#Set url and button text
			#Currently works for models with link defined
			#groups, discussions
			if defined? tag.url
				@url = tag.url
				@button_text = "Go to #{tag.class.to_s}"
			elsif tag.class.to_s == "Interview"
				#Interview requires special case
				#base off of who owns interview
				if user_id == tag.user_id
					@url = "users/#{user_id}/applications"
				else
					@url = "groups/#{tag.job.group.to_param}/jobs/#{tag.job.id}/applications"
				end
				@button_text = "Go to Applications"
			end
		end

		mail = mail(:to => @user.email, :subject => name+' messaged you: '+subject)

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('message_notification')
		end

		return mail
	end

	def interview_notification(user_id, job_id)  
		@user = User.find(user_id)
		@job = Job.find(job_id)

		mail = mail(:to => @user.email, :subject => 'You have a new interview request!')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('interview_notification')
		end

		return mail
	end

	def userconnect(owner_id, user_id)
		@owner = User.find(owner_id)
		@user = User.find(user_id)

 		# Which template to use
		#ab = Abtests.use("email:userconnect", 1).to_s
		#template = "userconnect_" + ab

		mail = mail(:to => @user.email, :subject => "Pending Tioki connection with #{@owner.name}!")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('userconnect')
		end

		return mail
	end

	def teacher_applied(group, job, user)
		@user = user
		@job = job

		#message_body = "Please login to tioki.com to respond to this request."
		subject = @user.name + ' applied to your job posting: ' + @job.title

		admins = group.users(:administrator).map(&:email)
		mail(:to => admins, :subject => subject)
	end

	# @Aleks look at this. It doesn't appear to be sending anything out.
	def interview_scheduled(user_id, job_id)
		@user = User.find(user_id)

		@job = Job.find(job_id)
		@school = School.find(@job.school_id)
		@admin_user = User.find(@school.owned_by)

		message_body = "Please login to tioki.com to view your interviewee's request."

		mail(:to => @admin_user.email, :subject => @user.name + ' has scheduled an interview', :body => message_body)

		@admins = SharedUsers.where(:owned_by => @admin_user.id).all
		@admins.each do |admin|
			shared =User.find(admin.user_id)
			if shared.is_limited ==false
				mail(:to => shared.email, :subject => @user.name + ' has scheduled an interview', :body => message_body)
			end
		end

		@limitedusers = SharedSchool.where(:school_id => @school.id).all
		@limitedusers.each do |limiteduser|
			shared = User.find(limiteduser.user_id)
			mail(:to => shared.email, :subject => @user.name + ' has scheduled an interview', :body => message_body)
		end
	end

	def deliver_forgot_password(email, name, pass)
		mail = mail(:to => email, :subject => '[Tioki] Password Reset', :body => "You have requested a password reset through our site. Your new password is:\n\n#{pass}\n\nPlease login and change it at your earliest convenience.\n\nRegards,\nThe Tioki Team\nhttp://tioki.com")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('deliver_forgot_password')
		end

		return mail
	end

	def send_passcode(name, email)
		@passcode = Passcode.find_by_given_out(nil)
		@passcode.given_out = true
		@passcode.sent_to = email
		@passcode.save!

		mail = mail(:to => email, :subject => 'Welcome to Tioki!', :body => "Hello and Welcome to Tioki!\n\nWe are thrilled to give you access to our revolutionary online hiring platform and cannot wait for you to start building your very own Tioki profile! Below you will find your personalized code that will grant you access to the site, as well as important terms of service you are agreeing to by signing up as a beta tester.\n\n 1) In appreciation for signing up as a beta tester, we will grant you FREE access to our site through March 31, 2012!\n\n 2) Please note that the site you are accessing is a soft launch of the site and does not represent the final product. We will add additional features in the future to optimize your experience!\n\n 3) Once you are on the site, please be sure to check out our exemplar profile page (the link is in the \"Edit Profile\" section of the site).  Also, please take the time to participate in our beta user survey, which will be emailed to you after you access the platform.\n\n 4) By clicking on the link below, you agree that this is a private and individual code for beta-testing purposes and that it is NOT TO BE SHARED with others. By clicking on the link below, you will gain access to the site, and be directed to create your personal url:\n\nhttp://tioki.com/signup?passcode=#{@passcode.code}\n\nIf you have any questions or need additional support please contact us at support@tioki.com.\n\nAgain, welcome to Tioki! We look forward to working with you to meet all your job searching needs!\n\nThe Tioki Team\n(323) 786-3366\ninfo@tioki.com")

			if mail.delivery_method.respond_to?('tag')
				mail.delivery_method.tag('send_passcode')
			end

		return mail
	end

	# INTERNAL
	def beta_notification(name, email, userType, beta)    
		userTypes = [ "Teacher", "Teacher Assistant", "Student Teacher", "Administrator" ]

		betaProgram = 'Not a tester'
		if beta == true
			betaProgram = "Applied"
			if userType == 1 || userType == 2 || userType == 3
				self.send_passcode(name, email).deliver
			end
		end

		mail = mail(:to => 'tioki@tioki.com', :subject => '[Tioki] New Beta Signup', :body => "A new user has registered via the landing page.\n\nName: #{name}\nEmail: #{email}\n\nUser Type: #{userTypes[userType-1]}\nBeta Program: #{betaProgram}")

			if mail.delivery_method.respond_to?('tag')
				mail.delivery_method.tag('beta_notification')
			end

		return mail
	end

	def refer_job_email(teachername, job_id, name, emails)
		@job = Job.find(job_id)
		@name = name
		@teachername = teachername

		subject =  @teachername+' has referred you to a job, '+@job.title+' on Tioki!!'

		# Which template to use
		ab = Abtests.use("email:refer_job", 0).to_s
		template = "refer_job_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => subject) do |f|
			f.html { render template }
		end
		#:body => "Hi #{name}! "+@teachername+" wants you too check out the job, "+@job.title+", posted by "+@job.school.name+" on Demo Lesson! Click on the following link to view the job posting: http://www.demolesson.com/jobs/#{@job.id}\n\nIf you have any questions or need additional support please contact us at support@tioki.com.")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('refer_job_email:ab-' + ab)
		end

		return mail

	end

	def refer_site_email(teachername, emails, message, user = nil)

		# Set variables for use inside the email itself
		@teachername = teachername
		@message = message

		# Get the refering ID
		@referer = user.id unless user.nil?

		# Set the subject for the email
		subject =  @teachername+' wants you to check out Tioki!'

		# Which template to use
		ab = Abtests.use("email:refer_site_generic", 1).to_s
		template = "refer_site_generic_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => subject) do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('refer_site_email:ab-' + ab)
		end

		return mail
	end

	def event_invite_email(teachername, emails, message, event, user = nil)

		# Set variables for use inside the email itself
		@teachername = teachername
		@message = message

		# Source the event itself
		@event = event

		# Get the refering ID
		@referer = user.id unless user.nil?

		# Set the subject for the email
		subject =  @teachername+' wants you to check out an upcoming event on Tioki!'

		# Which template to use
		ab = Abtests.use("email:event_invite", 1).to_s
		template = "event_invite_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => subject) do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('event_invite_email:ab-' + ab)
		end

		return mail
	end
	
	def group_invite_email(teachername, emails, message, group, user = nil)

		# Set variables for use inside the email itself
		@teachername = teachername
		@message = message

		# Source the event itself
		@group = group

		# Get the refering ID
		@referer = user.id unless user.nil?

		# Set the subject for the email
		subject =  @teachername+' wants you to check out this Group on Tioki!'

		# Which template to use
		ab = Abtests.use("email:group_invite", 1).to_s
		template = "group_invite_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => subject) do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('group_invite_email:ab-' + ab)
		end

		return mail
	end
	
	def discussion_invite_email(teachername, emails, message, discussion, user = nil)

		# Set variables for use inside the email itself
		@teachername = teachername
		@message = message

		# Source the discussion itself
		@discussion = discussion

		# Get the refering ID
		@referer = user.id unless user.nil?

		# Set the subject for the email
		subject =  @teachername+' wants you to check out this Discussion on Tioki!'

		# Which template to use
		ab = Abtests.use("email:discussion_invite", 1).to_s
		template = "discussion_invite_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => subject) do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('discussion_invite_email:ab-' + ab)
		end

		return mail
	end

	# @Aleks don't think these are being sent
	def school_signup_email(name, schoolname, email, phonenumber, school)
		@name = name
		@schoolname = schoolname
		@email = email
		@phonenumber = phonenumber

		subject =  @schoolname+' just signed up to Tioki for a free trial, please contact them to discuss their free trial.'
		body = "Name:"+@name+"\n\nSchool name:"+@schoolname+"\n\nPhone Number:"+@phonenumber+"\n\nhttp://www.tioki.com/schools/"+school.id.to_s

		mail(:to => 'schumacher.hodge@tioki.com', :subject => subject, :body => body)
		mail(:to => 'support@tioki.com', :subject => subject, :body => body)
	end

	def rejection_notification(user_id, job_id, name)  
		@user = User.find(user_id)
		@job = Job.find(job_id)
		@school = School.find(@job.school_id)
		@admin_user = User.find(@school.owned_by)

		mail = mail(:to => @user.email, :subject => 'Your application status has changed.')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('rejection_notification')
		end

		return mail
	end

	def vouch_request(voucheename, vouchername, emails, url)
		@url = url
		@teachername = voucheename
		@name = vouchername

		# Which template to use
		ab = Abtests.use("email:vouch_request", 1).to_s
		template = "vouch_request_" + ab

		# Send out the email
		mail = mail(:to => emails, :subject => @teachername + " has requested to verify their skills on Tioki") do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('vouch_request:ab-' + ab)
		end

		return mail
	end

	def connection_invite(user, emails, url, message, ab)
		@username = user.name
		@url = url
		@message = message
		@user = user

		# Which template to use
		template = "connection_invite_" + ab

		mail = mail(:to => emails, :subject => @username + " wants to connect on Tioki!") do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('connection_invite:ab-' + ab)
		end

		return mail
	end

	def five_referrals(email)
		mail = mail(:to => email, :subject => 'Congratulations!')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('five_referrals')
		end

		return mail
	end

	def skills_vouched(vouchee_id, voucher_id, start_time)
		vouchee = User.find(vouchee_id)
		voucher = User.find(voucher_id)
		email = vouchee.email
		@profile_name = vouchee.slug
		@vouched_skills = VouchedSkill.where("user_id = ? && voucher_id = ? && created_at >= ?", vouchee.id, voucher.id, start_time).limit(6).all
		@sender_name = voucher.name
		@receiver_name = vouchee.name

		ab = Abtests.use("email:skills_vouched",1)
		if ab == 0
			subject = @sender_name + " has vouched for your skills."
		else
			subject = @sender_name + " thinks you have amazing skills."
		end
		mail = mail(:to => email, :subject => @sender_name + " has vouched for your skills.")

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('skill_vouched:ab-' + ab.to_s)
		end

		return mail
	end

	def credit_request_email(requested_number, credits_for_other_orgs, source, user)

		# Set variables for use inside the email itself
		@requested_number = requested_number
		@credits_for_other_orgs = credits_for_other_orgs

		# Source the org itself
		@organization = source

		# Get the User
		@user = user

		# Set the subject for the email
		subject =  'Job Credit Request'

		template = "credit_request_email"
		# Send out the email
		mail = mail(:to => 'sales@tioki.com', :subject => subject) do |f|
			f.html { render template }
		end

		return mail
	end
end
