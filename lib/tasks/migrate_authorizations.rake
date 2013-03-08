User.all.each do |user|
	# Twitter
	if user.authorizations[:twitter_access_token]
		begin
			client = Twitter::Client.new(
				:oauth_token => user.authorizations[:twitter_oauth_token],
				:oauth_token => user.authorizations[:twitter_oauth_secret]
			)
			twitter_user = client.user

			user.authentications.create!(:provider => 'twitter',
			                             :uid => twitter_user[:user_id],
			                             :token => user.authorizations[:twitter_oauth_token],
			                             :secret => user.authorizations[:twitter_oauth_secret])

		rescue
			# If access tokens are invalid don't do anything
		end
	end
	if user.authorizations[:facebook_access_token]
		begin
			graph = Koala::Facebook::API.new(self.current_user.authorizations['facebook_access_token'])

			user.authentications.create!(:provider => 'facebook',
			                             :uid => graph.get_object["me"],
			                             :token => user.authorizations[:facebook_access_token])
		rescue
			# If access tokens are invalid don't do anything
		end
	end
end
