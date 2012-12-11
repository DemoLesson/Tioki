APP_CONFIG_TMP = YAML.load_file("#{Rails.root}/config/config.yml")
APP_CONFIG = APP_CONFIG_TMP['default'].merge(APP_CONFIG_TMP[Rails.env])

# Load in custom date formats
APP_CONFIG['date_formats'].each{|df,str|Time::DATE_FORMATS[df.to_sym]=Proc.new{|time|time.strftime(str.gsub('%do', time.day.ordinalize))}}

# Load Twitter keys
if APP_CONFIG.has_key?('twitter')
	Twitter.configure do |config|
		# Consumer keys
		config.consumer_key = APP_CONFIG.twitter.consumer_key
		config.consumer_secret = APP_CONFIG.twitter.consumer_secret
	end
end
