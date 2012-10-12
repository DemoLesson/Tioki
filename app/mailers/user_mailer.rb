class UserMailer < ActionMailer::Base
	default :from => "Tioki <tioki@tioki.com>"

	def teacher_welcome_email(user_id)
		@user = User.find(user_id)
		@teacher = Teacher.find_by_user_id(user_id)

		# Get ab test number
		ab = Abtests.use("email:teacher_welcome", 1).to_s
		template "teacher_welcome_email_" + ab

		mail = mail(:to => @user.email, :subject => 'Welcome to Tioki!') do |f|
			f.html { render template }
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('teacher_welcome_email:ab-' + ab)
		end

		return mail
	end

	def teacher_welcome_email_temppassword(user_id, password)
		@user = User.find(user_id)
		@teacher = Teacher.find_by_user_id(user_id)
		@password = password

		mail = mail(:to => @user.email, :subject => 'Welcome to Tioki!')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('teacher_welcome_email_temppassword')
		end

		return mail
	end

	def message_notification(user_id, subject, body, id, name)
		@user = User.find(user_id)
		@subject = subject
		@message_body = body[0,140]
		@id = id
		@sender_name = name

		mail = mail(:to => @user.email, :subject => name+' messaged you: '+subject)

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('message_notification')
		end

		return mail
	end

	def interview_notification(teacher_id, job_id)  
		@teacher = Teacher.find(teacher_id)
		@user = User.find(@teacher.user_id)
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

		# Get the proper AB Test string
		ab = Abtests.use("email:userconnect", 1).to_s
		template = "userconnect_" + ab

		if ab == 0.to_s
			mail = mail(:to => @user.email, :subject => 'You have a new connection!') do |t|
				t.html { render template }
			end
		else
			mail = mail(:to => @user.email, :subject => "Pending Tioki connection with #{@owner.name}!") do |t|
				t.html { render template }
			end
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('userconnect:ab-' + ab)
		end

		return mail
	end

	# @Aleks look at this. It doesn't appear to be sending anything out.
	def teacher_applied(school_id, job_id, teacher_id)
		@school = School.find(school_id)
		@admin_user = User.find(@school.owned_by)

		@job = Job.find(job_id)
		@teacher = Teacher.find(teacher_id)
		@teacher_user = User.find(@teacher.user_id)

		message_body = "Please login to tioki.com to respond to this request."
		subject = @teacher_user.name+' applied to your job posting: '+@job.title

		mail(:to => @admin_user.email, :subject => subject)

		@admins = SharedUsers.find(:all, :conditions => { :owned_by => @admin_user.id })
		@admins.each do |admin|
			shared =User.find(admin.user_id)
			if shared.is_limited ==false
				mail(:to => shared.email, :subject => subject)
			end
		end

		@limitedusers = SharedSchool.find(:all, :conditions => { :school_id => @school.id})
		@limitedusers.each do |limiteduser|
			shared = User.find(limiteduser.user_id)
			mail(:to => shared.email, :subject => subject)
		end
	end

	# @Aleks look at this. It doesn't appear to be sending anything out.
	def interview_scheduled(user_id, job_id)
		@teacher_user = User.find(user_id)

		@job = Job.find(job_id)
		@school = School.find(@job.school_id)
		@admin_user = User.find(@school.owned_by)

		message_body = "Please login to tioki.com to view your interviewee's request."

		mail(:to => @admin_user.email, :subject => @teacher_user.name+' has scheduled an interview', :body => message_body)

		@admins = SharedUsers.find(:all, :conditions => { :owned_by => @admin_user.id })
		@admins.each do |admin|
			shared =User.find(admin.user_id)
			if shared.is_limited ==false
				mail(:to => shared.email, :subject => @teacher_user.name+' has scheduled an interview', :body => message_body)
			end
		end

		@limitedusers = SharedSchool.find(:all, :conditions => { :school_id => @school.id})
		@limitedusers.each do |limiteduser|
			shared = User.find(limiteduser.user_id)
			mail(:to => shared.email, :subject => @teacher_user.name+' has scheduled an interview', :body => message_body)
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
		#:body => "Hi #{name}! "+@teacher_user.name+" wants you too check out the job, "+@job.title+", posted by "+@job.school.name+" on Demo Lesson! Click on the following link to view the job posting: http://www.demolesson.com/jobs/#{@job.id}\n\nIf you have any questions or need additional support please contact us at support@tioki.com.")

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

	def rejection_notification(teacher_id, job_id, name)  
		@teacher = Teacher.find(teacher_id)
		@job = Job.find(job_id)
		@user = User.find(@teacher.user_id)
		@school = School.find(@job.school_id)
		@admin_user = User.find(@school.owned_by)

		mail = mail(:to => @user.email, :subject => 'Your application status has changed.')

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('rejection_notification')
		end

		return mail
	end

	def weeklyemail(teacher)
		@teacher=teacher
		#keywords for finding grades
		gradestring=["K","1","2","3","4","5","6","7","8","9","10","11","12", "elementary", "middle", "high","pre", "adult"]

		#must have emails enabled, be currently teacher
		#Still testing so emails are going to elijahgreen@gmail.com only
		tup = SmartTuple.new(" AND ")
		tup << ["jobs.created_at > ?", Date.today- 7.days]

		if teacher.seeking_location.present?
			#A loaction is a specific point in that location so a radius is needed.
			#Currently a 25 miles radius
			schools = School.near( teacher.seeking_location, 25).collect(&:id)

			#if no schools go to next teacher
			if schools.size == 0
				return
			else
				@jobs = Job.is_active.where(:school_id => schools).is_active.find(:all, :conditions => tup.compile)
			end
		else
			@jobs = Job.is_active.find(:all, :conditions => tup.compile)
		end

		if teacher.seeking_grade.present?
			jobarray = []

			#Elementary grades, K-6
			if gradestring[0..6].any? { |str| teacher.seeking_grade.include? str } || teacher.seeking_grade.downcase.include?("elementary")
				#2=elementary,7=K-6,8=K-8,10=K-12
				jobarray+=@jobs.select { |job| job.school.grades == 2 || job.school.grades == 8 || job.school.grades == 10 }
			end

			#Middle grades, 6-8 
			if gradestring[6..8].any? { |str| teacher.seeking_grade.include? str } || teacher.seeking_grade.downcase.include?("middle")
				#3=middle,8=K-8,9=6-12, 10=K-12
				jobarray+=@jobs.select { |job| job.school.grades == 3 || job.school.grades == 8 || job.school.grades == 9 || job.school.grades == 10 }
			end

			#High school grades, K-12
			if gradestring[9..12].any? { |str| teacher.seeking_grade.include? str } || teacher.seeking_grade.downcase.include?("high")
				#10=K-12, 9=6-12, 4 = high school
				jobarray+=@jobs.select { |job| job.school.grades == 9 || job.school.grades == 10 || job.school.grades == 4 }
			end

			#Pre-school
			if teacher.seeking_grade.downcase.include?("pre")
				#1=pre-K
				jobarray+=@jobs.select { |job| job.school.grades == 1 }
			end

			#Adult School
			if teacher.seeking_grade.downcase.include?("adult")
				jobarray+=@jobs.select { |job| job.school.grades == 5 }
			end

			@jobs=jobarray.uniq
		end

		if teacher.seeking_subject.present?
			#select subjects whose names is in seeking_subject
			@subjects=Subject.all.select { |subject| teacher.seeking_subject.include? subject.name }

			jobarray = []

			#any jobs with a particular subject is added to the array, because of this there are possibly duplicates
			@subjects.each do |subject|
				jobarray+=@jobs.select{ |job| JobsSubjects.find(:first, :conditions => [ "job_id = ? AND subject_id = ?", job.id, subject.id]) != nil }
			end
			#make sure that every job of the jobs array is unique
			@jobs=jobarray.uniq
		end

		if @jobs.size > 0
			mail = mail(:to => teacher.user.email, :subject => "New job postings at tioki.com")
		end

		if mail.delivery_method.respond_to?('tag')
			mail.delivery_method.tag('weeklyemail')
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

	def connection_invite(user, emails, url, message)
		@teachername=user.name
		@url= url
		@message= message
		@user=user

		# Which template to use
		ab = Abtests.use("email:connection_invite", 1).to_s
		template = "connection_invite_" + ab

		# Send out the email
		# Use new subject lines
		if ab == 0.to_s
			mail = mail(:to => emails, :subject => @teachername + " wants you to checkout Tioki!") do |f|
				f.html { render template }
			end
		else
			mail = mail(:to => emails, :subject => @teachername + " wants to connect on Tioki!") do |f|
				f.html { render template }
			end
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
		@profile_name = vouchee.teacher.url
		@vouched_skills = VouchedSkill.find(:all, :conditions => ["user_id = ? && voucher_id = ? && created_at >= ?", vouchee.id, voucher.id, start_time], :limit => 6)
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
end
