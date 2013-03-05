Rails.application.config.middleware.use OmniAuth::Builder do
	provider :developer unless Rails.env.production?
	provider :twitter, APP_CONFIG.twitter.consumer_key, APP_CONFIG.twitter.consumer_secret
end
