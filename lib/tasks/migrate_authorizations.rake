desc "Migrate authorizations to a new table"
task :migrate_authorizations => :environment do
	User.all.each do |user|
		if user.authorizations[:twitter_oauth_token]

			begin
				client = Twitter::Client.new(
					:oauth_token => user.authorizations[:twitter_oauth_token],
					:oauth_token_secret => user.authorizations[:twitter_oauth_secret]
				)

				twitter_user = client.user

				user.authentications.create!(:provider => 'twitter',
				                             :uid => twitter_user.id.to_s,
				                             :token => user.authorizations[:twitter_oauth_token],
				                             :secret => user.authorizations[:twitter_oauth_secret])

			rescue
				# If access tokens are invalid don't do anything
			end
		end
		if user.authorizations[:facebook_access_token]
			begin
				graph = Koala::Facebook::GraphAPI.new(user.authorizations[:facebook_access_token])

				user.authentications.create!(:provider => 'facebook',
				                             :uid => graph.get_object("me").id,
				                             :token => user.authorizations[:facebook_access_token])
			rescue
				# If access tokens are invalid don't do anything
			end
		end
	end
end
