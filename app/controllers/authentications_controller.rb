class AuthenticationsController < ApplicationController
	before_filter :login_required, :except => [:create]

	def create
		omniauth = request.env["omniauth.auth"]

		authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

		if authentication && self.current_user.nil?
			session[:user] = authentication.user
			redirect_to :root
		elsif self.current_user
			if authentication
				# update authentiaction with new info
				authentication.update_attributes(:token => omniauth[:credentials][:token],
				                                 :secret => omniauth[:credentials][:secret])
			else
				self.current_user.authentications.
					create!(:provider => omniauth['provider'],
				          :uid => omniauth['uid'],
				          :token => omniauth[:credentials][:token],
				          :secret => omniauth[:credentials][:secret])
			end
			redirect_to redirect_after_auth(params)
		else
			session[:omniauth] = omniauth
			redirect_to '/welcome_wizard?x=step1'
		end
	end

	def twitter_callback
		auth = self.current_user.authentications.where(:provider => 'twitter').first

		client = Twitter::Client.new(
			:oauth_token => auth.token,
			:oauth_token_secret => auth.secret
		)

		if params[:twitter_action] == "tweet"
			client.update("I just joined Tioki; a professional networking site for educators.  " +
			              "You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code} via @tioki")

		elsif params[:twitter_action] == "auth"
			return redirect_to "/me/settings", :notice => "Success"

		elsif params[:twitter_action] == "whiteboard_auth" && session[:whiteboard_id]
			return redirect_to whiteboard_share_twitter_authentications_url(
				:whiteboard_id => session[:whiteboard_id])

		elsif params[:twitter_action] == "inviteconnections"
			return redirect_to "/inviteconnections/twitter"
		end
		redirect_to :root
	end

	def facebook_callback
		auth = self.current_user.where(:provider => 'twitter').first

		if params[:facebook_action] == "auth"
			return redirect_to "/me/settings", :notice => "Success"

		elsif params[:facebook_action] == "whiteboard_auth" && session[:whiteboard_id]
			whiteboard = Whiteboard.find(session[:whiteboard_id])

			return redirect_to whiteboard_share_facebook_authentications_url(
				:whiteboard_id => whiteboard.id)

		elsif session[:facebook_action] == "wall_post"
			@graph = Koala::Facebook::API.new(auth.token)
			@graph.put_wall_post("I just joined Tioki; a professional networking site for educators.  " +
			                     "You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code}")

			return redirect_to "/tioki_bucks", :notice => "Successfully added a tioki wall post."
		end
		redirect_to :root
	end

	def linkedin_callback
		@user = self.current_user
		client = LinkedIn::Client.new(APP_CONFIG.linkedin.api_key, APP_CONFIG.linkedin.app_secret)
		pin = params[:oauth_verifier]
		client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

		#begin populating profile
		#set teacher.linkedin
		user = client.profile(:fields => %w(public-profile-url))
		@user.social << {:linkedin => user.public_profile_url}

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
				education = @user.educations.build(
					:school => school, :degree => degree,
					:concentrations => concentrations,
					:year => year)

				education.save
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
				experience = @user.experiences.build(
					:company => company,
					:position => positiontitle,
					:startMonth => startMonth,
					:startYear => startYear,
					:endMonth => endMonth,
					:endYear => endYear,
					:current => current)

				experience.save
			end
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
			@user.contact << {:phone => phone}
		end

		#Linkedin integration is currently a one time thing so deleting session keys
		#and redirecting to profile like create_profile does
		session[:rtoken] = nil
		session[:rsecret] = nil

		# Redirect to a different location
		unless session[:linkedin_redirect].nil?
			redirect = session[:linkedin_redirect]
			session[:linkedin_redirect] = nil
			return redirect_to redirect
		end

		# Redirect back to the profile
		redirect_to '/profile/' + self.current_user.slug
	end

	def whiteboard_share_twitter
		client = Twitter::Client.new(
			:oauth_token => self.current_user.authorizations['twitter_oauth_token'],
			:oauth_token_secret => self.current_user.authorizations['twitter_oauth_secret']
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

		if session[:share_on_facebook]
				session[:share_on_facebook] = nil
			if self.current_user.authorizations['facebook_access_token']
				return redirect_to whiteboard_share_facebook_authentications_url(:whiteboard_id => whiteboard.id)
			else
				session[:whiteboard_id] = whiteboard.id
				return redirect_to create_authentications_url(:facebook_action => "whiteboard_auth")
			end
		end

		redirect_to :root, :notice => notice
	end

	def whiteboard_share_facebook
		@graph = Koala::Facebook::API.new(self.current_user.authorizations['facebook_access_token'])
		whiteboard = Whiteboard.find(params[:whiteboard_id])

		message = ActionController::Base.helpers.strip_links(whiteboard.message)

		begin
			@graph.put_wall_post(message)
		rescue Koala::Facebook::APIError => ex
			if ex.fb_error_code == 190
				#Oauthexception
				#most likely bad or expired oauth keys
				session[:whiteboard_id] = whiteboard.id
				return redirect_to create_authentications_url(:facebook_action => "whiteboard_auth")
			else
				#raise error so that it can be logged
				#there are possible some errors that we aren't dealing with
				raise ex
			end
		end

		redirect_to :root, :notice => notice
	end

	def revoke_twitter
		self.current_user.authentications.where(:provider => 'twitter').destroy_all

		redirect_to "/me/settings"
	end

	def revoke_facebook
		self.current_user.authentications.where(:provider => 'facebook').destroy_all
		redirect_to "/me/settings"
	end
	
	private

	def redirect_after_auth(args)
		if args[:provider] == 'twitter'
			case args[:twitter_action]
			when 'auth'
				'/twitter_callback?twitter_action=auth'
			when 'whiteboard'
				'/twitter_callback?twitter_action=whiteboard'
			when 'tweet'
				'/twitter_callback?twitter_action=tweet'
			end
		elsif args[:provider] == 'facebook'
			case args[:facebook_action]
			when 'auth'
				'/twitter_callback?facebook_action=auth'
			when 'whiteboard'
				'/facebook_callback?facebook_action=whiteboard'
			end
		else
			'/'
		end
	end
end
