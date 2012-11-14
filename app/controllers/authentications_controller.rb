class AuthenticationsController < ApplicationController
	before_filter :login_required

	def twitter_auth
		callback_url = "http://#{request.host_with_port}/twitter_callback"
		request_token = twitter_oauth.get_request_token(:oauth_callback => callback_url)
		session[:rtoken] = request_token.token
		session[:rsecret] = request_token.secret
		session[:twitter_action] = params[:twitter_action]

		redirect_to request_token.authorize_url
	end

	def twitter_callback
		request_token = OAuth::RequestToken.new(twitter_oauth, session[:rtoken], session[:rsecret])
		access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

		client = Twitter::Client.new(
			:oauth_token => access_token.token,
			:oauth_token_secret => access_token.secret
		)

		if session[:twitter_action] == "follow"
			client.follow("Tioki")
			self.current_user.teacher.update_attribute(:twitter_connect, true)
			notice = "You are now following tioki"
		elsif session[:twitter_action] == "tweet"
			client.update("I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code} via @tioki")
			self.current_user.teacher.update_attribute(:tweet_about, true)
			notice = "Success"
		elsif session[:twitter_action] == "auth"
			self.current_user.update_attribute(:twitter_oauth_token, access_token.token)
			self.current_user.update_attribute(:twitter_oauth_secret, access_token.secret)
			notice = "Success"
		elsif session[:twitter_action] == "whiteboard_auth" && session[:whiteboard_id]
				self.current_user.update_attribute(:twitter_oauth_token, access_token.token)
				self.current_user.update_attribute(:twitter_oauth_secret, access_token.secret)
				whiteboard = Whiteboard.find(session[:whiteboard_id])

				session[:whiteboard_id] = nil
				session[:rsecret] = nil
				session[:rtoken] = nil
				session[:twitter_action] = nil

				return redirect_to whiteboard_share_twitter_authentications_url(:whiteboard_id => whiteboard.id)
		end

		#no longer need these session variables
		session[:rsecret] = nil
		session[:rtoken] = nil

		if session[:twitter_action] == "auth"
			redirect_to "/me/settings", :notice => notice
			session[:twitter_action] = nil
		else
			redirect_to "/tioki_bucks", :notice => notice
			session[:twitter_action] = nil
		end
	end

	def revoke_twitter
		self.current_user.update_attribute(:twitter_oauth_token, nil)
		self.current_user.update_attribute(:twitter_oauth_secret, nil)
		redirect_to "/me/settings"
	end

	def facebook_auth
		@oauth = facebook_oauth
		redirect_to @oauth.url_for_oauth_code(:permissions => "publish_stream")
	end

	def facebook_callback
		access_token = facebook_oauth.get_access_token(params[:code])

		@graph = Koala::Facebook::API.new(access_token)

		@graph.put_wall_post("I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code}")
		self.current_user.teacher.update_attribute(:facebook_connect, true)

		redirect_to "/tioki_bucks", :notice => "Successfully added a tioki wall post."
	end

	def revoke_facebook
	end

	def linkedin_callback
		@teacher = Teacher.find(self.current_user.teacher.id)
		client = LinkedIn::Client.new(APP_CONFIG.linkedin.api_key, APP_CONFIG.linkedin.app_secret)
		pin = params[:oauth_verifier]
		client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

		#begin populating profile
		#set teacher.linkedin
		user = client.profile(:fields => %w(public-profile-url))
		@teacher.update_attribute(:linkedin, user.public_profile_url)

		#educations
		user = client.profile(:fields => %w(educations))
		if user.educations.all != nil
			user.educations.all.each do |education|
				school = education.school_name
				degree = education.degree
				concentrations = education.field_of_study
				if education.end_date
					year = education.end_date.year
				end
				@teacher.educations.build(:school => school, :degree => degree, :concentrations => concentrations, :year => year)
				@teacher.save
			end
		end

		#positions
		user = client.profile(:fields => %w(positions))
		currentposition=nil
		currentschool=nil
		if user.positions.all != nil
			user.positions.all.each do |position|
				company = position.company.name
				positiontitle = position.title
				if position.start_date
					startMonth = position.start_date.month
					startYear = position.start_date.year
				end
				if position.is_current == true
					endMonth = Time.now.month
					endYear = Time.now.year
					current = true
					if position.company.industry == "Primary/Secondary Education"
						currentposition = position.title
						currentschool = position.company.name
					end
				else
					endMonth = position.end_date.month
					endYear = position.end_date.year
					current = false
				end
				@teacher.experiences.build(:company => company, :position => positiontitle, :startMonth => startMonth, :startYear => startYear, :endMonth => endMonth, :endYear => endYear, :current => current)
				@teacher.save
			end
		end
		if currentschool != nil && currentposition != nil
			@teacher.update_attribute(:school, currentschool)
			@teacher.update_attribute(:position, currentposition)
		end

		#phone number
		user= client.profile(:fields => %w(phone-numbers))
		phone=nil
		if user.phone_numbers.all != nil
			user.phone_numbers.all.each do |number|
				if number.phone_type == "home" || number.phone_type == "mobile"
					phone = number.phone_number
					break
				end
			end
		end
		if phone != nil
			@teacher.update_attribute(:phone, phone)
		end

		#Addtional Information:
		addinfo = ""
		#Interests
		user =client.profile(:fields => %w(interests))
		if user.interests != nil
			addinfo = "Interests: " + user.interests
		end
		#groups and associations
		user =client.profile(:fields => %w(associations))
		if user.associations != nil
			addinfo = addinfo + "\nGroups and Associations: " + user.associations
		end
		#honors
		user =client.profile(:fields => %w(honors))
		if user.honors != nil
			addinfo = addinfo + "\nHonors: " + user.honors
		end
		@teacher.update_attribute(:additional_information, addinfo)

		#Linkedin integration is currently a one time thing so deleting session keys
		#and redirecting to profile like create_profile does
		session[:rtoken]=nil
		session[:rsecret]=nil
		redirect_to '/profile/'+self.current_user.teacher.url     
	end

	def whiteboard_share_twitter
		client = Twitter::Client.new(
			:oauth_token => self.current_user.twitter_oauth_token,
			:oauth_token_secret => self.current_user.twitter_oauth_secret
		)
		whiteboard = Whiteboard.find(params[:whiteboard_id])
		whiteboard_message = ActionController::Base.helpers.strip_links(whiteboard.message)

		#140 characters minus the via @tioki
		#" via @tioki" being 11 chars
		if whiteboard_message.size > 128
			message = "#{whiteboard_message[0..125]}... via @tioki"
		else
			message = "#{whiteboard_message} via @tioki"
		end

		begin
			client.update(message)
		rescue Twitter::Error::Unauthorized
			#Old auth keys, need new ones
			session[:whiteboard_id] = whiteboard.id
			return redirect_to "/twitter_auth?twitter_action=whiteboard_auth"
		end
		redirect_to :root, :notice => notice
	end
end
