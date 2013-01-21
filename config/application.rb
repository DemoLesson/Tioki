require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'will_paginate/array'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Preview
	class Application < Rails::Application
		Paperclip::Railtie.insert
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Custom directories with classes and modules you want to be autoloadable.
		# config.autoload_paths += %W(#{config.root}/extras)

		# Only load the plugins named here, in the order given (default is alphabetical).
		# :all can be used as a placeholder for all plugins not explicitly named.
		# config.plugins = [ :exception_notification, :ssl_requirement, :all ]

		# Activate observers that should always be running.
		# config.active_record.observers = :cacher, :garbage_collector, :forum_observer

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		# config.time_zone = 'Central Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :de

		# Configure the default encoding used in templates for Ruby 1.9.
		config.encoding = "utf-8"
		config.server_static_assets = true

		# Configure sensitive parameters which will be filtered from the log file.
		config.filter_parameters += [:password]

		# Enable the asset pipeline
		config.assets.enabled = true
		config.action_controller.allow_forgery_protection = false

		# Paperclip Amazon S3 Connect
		config.paperclip_defaults = {
			:storage => :fog,
			:fog_credentials => {
				:provider => 'AWS',
				:aws_access_key_id => 'AKIAJIHMXETPW2S76K4A',
				:aws_secret_access_key  => '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',
				:region => 'us-west-2'
			},
			:fog_public => true,
			:fog_directory => 'tioki',
			:path => "#{Rails.env}/:class/:id/:style/:basename.:extension",
			:processors => [:timestamper],
			:date_format => "%Y%m%d%H%M%S"
		}

	end
end

# Include any Globals
Dir.glob("./globals/*.{rb}").each do |file|
	require file
end

# Load Ruby Tracer
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'proc_trace'))
