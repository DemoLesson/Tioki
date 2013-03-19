Rails.application.config.middleware.use OmniAuth::Builder do
	provider :twitter, APP_CONFIG.twitter.consumer_key, APP_CONFIG.twitter.consumer_secret
	provider :facebook, APP_CONFIG.facebook.api_key, APP_CONFIG.facebook.app_secret,
	         :scope => 'email,publish_stream,user_education_history,user_location,user_work_history'
end
