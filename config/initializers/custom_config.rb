APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

if APP_CONFIG.has_key?('twitter')
	Twitter.configure do |config|
		# Consumer keys
		config.consumer_key = APP_CONFIG.twitter.consumer_key
		config.consumer_secret = APP_CONFIG.twitter.consumer_secret

		# oAuth Tokens
		config.oauth_token = APP_CONFIG.twitter.oauth_token
		config.oauth_token_secret = APP_CONFIG.twitter.oauth_token_secret
	end
end