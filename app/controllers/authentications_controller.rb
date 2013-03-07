class AuthenticationsController < ApplicationController
	before_filter :login_required, :except => [:create]

	def create
		omniauth = request.env["omniauth.auth"]

		authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

		if authentication && self.current_user.nil?
			session[:user] = authentication.user_id
			redirect_to :root
		elsif self.current_user
			if authentication
				self.current_user.authentications.
					where(:provider => omniauth['provider']).first.
					update_attributes(:uid => omniauth['uid'],
					                  :token => omniauth[:credentials][:token],
					                  :secret => omniauth[:credentials][:secret])
			else
				self.current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
			end
			redirect_to redirect_after_auth(params)
		else
			session[:omniauth] = omniauth
			redirect_to '/welcome_wizard?x=step1'
		end
	end

	def twitter_callback
		request_token = OAuth::RequestToken.new(twitter_oauth, session[:rtoken], session[:rsecret])
		access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

		client = Twitter::Client.new(
			:oauth_token => access_token.token,
			:oauth_token_secret => access_token.secret
		)

		self.current_user.authorizations = self.current_user.authorizations.merge({
			:twitter_oauth_token =>  access_token.token,
			:twitter_oauth_secret => access_token.secret
		})

		#don't need these anymore
		session[:rsecret] = nil
		session[:rtoken] = nil

		if session[:twitter_action] == "tweet"
			client.update("I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code} via @tioki")
			session[:twitter_action] = nil

			notice = "Success"

			if session[:wizard_url]
				return redirect_to session[:wizard_url]
			else
				return redirect_to "/welcome_wizard?x=step4"
			end

		elsif session[:twitter_action] == "auth"
			session[:twitter_action] = nil
			notice = "Success"

			return redirect_to "/me/settings", :notice => notice
		elsif session[:twitter_action] == "whiteboard_auth" && session[:whiteboard_id]

			return redirect_to whiteboard_share_twitter_authentications_url(
				:whiteboard_id => session[:whiteboard_id]
			)

		elsif session[:twitter_action] == "get_contacts"
			session[:twitter_action] = nil

			if session[:wizard_url]
				return redirect_to "#{session[:wizard_url]}&twitter_contacts=true"
			else
				return redirect_to "/welcome_wizard?x=step4&twitter_contacts=true"
			end
		elsif session[:twitter_action] == "inviteconnections"
			session[:twitter_action] = nil
			return redirect_to "/inviteconnections/twitter"
		end
		redirect_to :root
	end

	def facebook_callback
		access_token = facebook_oauth.get_access_token(params[:code])

		self.current_user.authorizations = self.current_user.authorizations.merge({
			:facebook_access_token => access_token
		})

		if session[:facebook_action] == "auth"
			session[:facebook_action] = nil

			return redirect_to "/me/settings"

		elsif session[:facebook_action] == "whiteboard_auth" && session[:whiteboard_id]
			whiteboard = Whiteboard.find(session[:whiteboard_id])

			session[:whiteboard_id] = nil
			session[:facebook_action] = nil

			return redirect_to whiteboard_share_facebook_authentications_url(
				:whiteboard_id => whiteboard.id)

		elsif session[:facebook_action] == "wall_post"
			session[:facebook_action] = nil
			@graph = Koala::Facebook::API.new(access_token)
			@graph.put_wall_post("I just joined Tioki; a professional networking site for educators.  You should connect with me! http://www.tioki.com/dc/#{self.current_user.invite_code}")

			return redirect_to "/tioki_bucks", :notice => "Successfully added a tioki wall post."
		end
		redirect_to :root
	end

	def linkedin_callback
		@user = self.current_user
		client = LinkedIn::Client.new(APP_CONFIG.linkedin.api_key, APP_CONFIG.linkedin.app_secret)
		pin = params[:oauth_verifier]
		client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

		# Deprecate
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

	# todo change to new table
	def revoke_twitter
		self.current_user.authentications.where(:provider => 'twitter').destroy_all

		redirect_to "/me/settings"
	end

	# TODO change to new table
	def revoke_facebook
		self.current_user.authentications.where(:provider => 'facebook').destroy_all
		redirect_to "/me/settings"
	end
	
	private

	def redirect_after_auth(args)
		if args[:provider] == 'twitter'
			case args[:action]
			when 'auth'
				'/twitter_callback?twitter_action=auth'
			when 'whiteboard'
				'/facebook_callback?twitter_action=whiteboard'
			when 'tweet'
				'/facebook_callback?twitter_action=tweet'
			end
		else
			'/'
		end
	end
end
