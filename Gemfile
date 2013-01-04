source 'http://rubygems.org'

# Rails Itself
gem 'rails', '3.1.3'
# (Bleeding Edge) # gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-1-stable'

# Database Handler
gem 'mysql2'

# Production only gems
group :production do
	gem 'therubyracer', '~> 0.9.3.beta1'
end

# Assets
# @todo remove these gems from running in production
#group :assets do
	gem 'sprockets' # Assets pipeline
	gem 'coffee-script' # Coffeescript
	gem 'uglifier' # Minify JS
	gem 'sass-rails' # SCSS Sheets
#end

# Tiny-MCE / jQuery need to be global
gem 'jquery-rails'
gem 'tinymce-rails'

# Social Networks and oAuth
gem 'oauth'
gem 'linkedin'
gem 'twitter'
gem 'koala' # Facebook

# General APIs
gem 'cloudsponge', '~> 0.9.9'
gem 'zencoder', '~> 2.4.0'
# @todo build a new mailgun extension
gem 'mailgun-rails', :git => 'git://github.com/KellyLSB/mailgun-rails.git' # Mailgun API Access

# Ruby extenions
gem 'multimap' # Ruby Multimapper
gem 'bitswitch', :git => 'git://github.com/KellyLSB/Bitswitch.git' #, :path => '/Users/kbecker/Development/ruby/bitswitch' # Bitwise Booleans
gem 'kvpair', :git => 'git://github.com/KellyLSB/KVPair.git' # Rails 3.1 Key => Value Pairs
gem 'dnsruby' # Provides DNS Record Details
gem 'chronic' # Relative time engine
gem 'gibberish' # Encryption
gem 'httparty' # HTTP Client
gem 'delayed_job_active_record' # Delayed Jobs
gem 'daemons' # Ruby Daemons / Delayed Job Dependency
gem 'uuidtools' # Universal Unique ID Generator
gem 'geocoder' # Geocoder / Reverse Geocoder
gem 'os' # Users operating system information
gem 'htmlentities' # HTML entities helper
gem 'possessive' # Intelligent possesification
gem 'mini_magick' # ImageMagick support
gem 'acts_as_commentable_with_threading' # Threaded Comments
gem 'will_paginate', '~> 3.0.3' # Active Record Pagination
# @todo deprecate smart_tuple replace with solr
gem 'smart_tuple' # Tuple styled SQL Queries

# @todo cleanup file upload process
# @todo depreciate paperclip in favor of carrierwave
# File Uploading/Storage
gem 'paperclip', '~> 3.3.0' # Depreciate
gem 'aws-sdk', '~> 1.3.4'
gem 'aws-s3', :require => 'aws/s3'
gem 'carrierwave' # Use instead of paperclip
gem 'carrierwave_direct' # Direct uploads to S3
gem 'remotipart', '~> 0.4.1' # Do we actually need this
gem 'fog'

# Webserver
gem 'unicorn'

# Deploy script notifications
gem 'terminal-notifier'

# Rubber deployments
gem 'rubber'
gem 'open4'

# Debug tools
group :development do
	gem 'debugger'
	gem 'debugger-ruby_core_source'
end

# Graylog2
gem 'gelf'
gem 'graylog2_exceptions', :git => 'git://github.com/wr0ngway/graylog2_exceptions.git'
gem 'graylog2-resque'

# New Relic
gem 'newrelic_rpm'
gem 'json', '1.7.6'
