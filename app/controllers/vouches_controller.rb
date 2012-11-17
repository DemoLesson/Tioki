class VouchesController < ApplicationController
	before_filter :login_required, :only => [:addvouch]

	def vouchrequest
		if params[:skills] == nil || params[:skills].size == '0'
			return redirect_to :back, :notice => "You must choose at least one of your skills to be vouched in."
		end
		user = User.find(:first, :conditions => ["email = ?", params[:vouch][:email]])
		@vouch = Vouch.new(params[:vouch])
		@vouch.vouchee_id= self.current_user.id
		#using a random string + the user_id and vouch_id to create a unique address
		vouchinfo=User.random_string(20)
		if params[:is_teacher] == nil || params[:is_teacher] == '0' 
			#Just request email
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s )
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email],url).deliver
				redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		elsif user != nil
			#Send a vouch request email
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				if params[:skills_for_teacher]
					params[:skills_for_teacher].each do |skill|
						VouchedSkill.create(:user_id => user.id, :skill_id => skill, :voucher_id => User.current.id)
					end
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s)
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email],url).deliver
				redirect_to '/profile/'+User.current.teacher.url
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		else
			#Person is teacher without an account with demolesson
			@vouch.for_new_educator = true
			if @vouch.save
				params[:skills].each do |skill|
					SkillToVouch.create(:skill_id => skill, :vouch_id => @vouch.id)
				end
				if params[:skills_for_teacher]
					params[:skills_for_teacher].each do |skill|
						ReturnedSkill.create(:vouch_id => @vouch.id, :skill_id => skill)
					end
				end
				@vouch.update_attribute(:url, vouchinfo+@vouch.id.to_s)
				url="http://#{request.host_with_port}/vouchresponse?u=" + @vouch.url
				UserMailer.vouch_request(self.current_user.name, @vouch.first_name, params[:vouch][:email], url).deliver
				redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
			else
				redirect_to :back, :notice => @vouch.errors.full_messages.to_sentence
			end
		end
	end

	def addvouch
		# Unauthorized if you are trying to vouch your own skill
		raise HTTPStatus::Unauthorized if params[:user_id] == User.current.id

		# Have you already vouched for this skill?
		vouched_skill = VouchedSkill.find(:first, :conditions => ['skill_id = ? && voucher_id = ? && user_id = ?', params[:skill_id], User.current.id, params[:user_id]])

		# Already vouched
		return redirect_to :back, :notice => "You have already vouched for this skill" if vouched_skill
		
		# Create a new vouch
		vouch = VouchedSkill.create(:skill_id => params[:skill_id], :user_id => params[:user_id], :voucher_id => User.current.id)

		#Inform vouchee of the vouch five minutes later to give time for voucher to add more vouches
		#first search for existing
		user_delayed_job = UserDelayedJob.find(:first, :conditions =>["user_id = ? && vouchee_id = ?", User.current.id, params[:user_id]])

		if user_delayed_job
			prev_delayed_job = Delayed::Job.find_by_id(user_delayed_job.delayed_job_id)

			#check if previous job exists and delete as we are going to create a new one
			if prev_delayed_job
				prev_delayed_job.destroy
			else
				#user_delayed_job is invalid
				#needs new time
				user_delayed_job.action_start = vouch.created_at
			end
		else
			user_delayed_job = UserDelayedJob.new(:user_id => User.current.id, :vouchee_id => params[:user_id], :action_start => vouch.created_at)
		end

		delayed_job= UserMailer.delay({:run_at => 3.minutes.from_now}).skills_vouched(params[:user_id], User.current.id, user_delayed_job.action_start)

		user_delayed_job.delayed_job_id = delayed_job.id

		user_delayed_job.save

		# Log to whiteboard and analytics
		Whiteboard.createActivity(:created_vouch, "{user.teacher.profile_link} vouched for {tag.teacher.profile_link} skills.", User.find(params[:user_id]))
		self.log_analytic(:created_vouch, "A user vouched for somones skills.", vouch)

		# Redirect to where you came from
		redirect_to :back
	end

	def updatevouch
		@vouch=Vouch.find(:last, :conditions => ["url = ?", params[:url]])
		user = User.find(:first, :conditions => ["users.email = ?", @vouch.email])
		params[:skills].each do |skill|
			if user
				VouchedSkill.create(:user_id=> @vouch.vouchee_id, :skill_id => skill, :vouch_id => @vouch.id, :voucher_id => user.id)
			else
				VouchedSkill.create(:user_id=> @vouch.vouchee_id, :skill_id => skill, :vouch_id => @vouch.id)
			end
		end
		@vouch.update_attribute(:pending, false)
		if @vouch.for_new_educator == true
			redirect_to "/welcome_wizard?x=step1&vouchstring=#{@vouch.url}", :notice => "Success"
		else
			redirect_to '/profile/'+User.current.teacher.url, :notice => "Success"
		end
	end

	def vouchresponse
		@vouch = Vouch.find(:first, :conditions =>["url = ?", params[:u]])

	end

	def vouch_connection_skills
		@invite = ConnectionInvite.find(params[:invite_id])
		unless @invite.created_user_id == self.current_user.id
			return redirect_to "/get_started"
		end

		# Install the skills
		if params[:skills]
			skills = Skill.where(:id => params[:skills].split(','))
			skills.each do |skill|
				VouchedSkill.create(:skill_id => skill.id, :user_id => @invite.user.id, :voucher_id => User.current.id)
			end
		end
		redirect_to "/get_started"
	end
end
