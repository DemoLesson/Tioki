source 'http://rubygems.org'

# Rails Itself
gem 'rails', '3.1.3'
# (Bleeding Edge) # gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-1-stable'

# Database Handler
gem 'mysql2'

# Assets
group :assets do
	gem 'sprockets' # Assets pipeline
	gem 'coffee-script' # Coffeescript
	gem 'uglifier' # Minify JS
	gem 'sass-rails' # SCSS Sheets
end

# Tiny-MCE / jQuery need to be global
gem 'jquery-rails'
gem 'tinymce-rails'

# @todo only have one of these
# HTTP Clients
gem 'httpclient'
gem 'httparty'
gem 'rest-client'

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
gem 'multimap'
gem 'bitswitch', :git => 'git://github.com/KellyLSB/Bitswitch.git' # Bitwise Booleans
gem 'kvpair', :git => 'git://github.com/KellyLSB/KVPair.git' # Rails 3.1 Key => Value Pairs
gem 'dnsruby' # Provides DNS Record Details
gem 'chronic' # Relative time engine
gem 'gibberish' # Encryption
gem 'delayed_job_active_record' # Delayed Jobs
gem 'daemons' # Ruby Daemons / Delayed Job Dependency
gem 'uuidtools' # Universal Unique ID Generator
gem 'geocoder' # Geocoder / Reverse Geocoder
gem 'os' # Users operating system information
gem 'htmlentities' # HTML entities helper
gem 'possessive' # Intelligent possesification
gem 'rmagick', :require => 'RMagick' # ImageMagick
gem 'acts_as_commentable_with_threading' # Threaded Comments
gem 'will_paginate', '~> 3.0.3' # Active Record Pagination
# @todo deprecate smart_tuple replace with solr
gem 'smart_tuple' # Tuple styled SQL Queries

# @todo cleanup file upload process
# File Uploading/Storage
gem 'paperclip', '~> 3.3.0'
gem 'aws-sdk', '~> 1.3.4'
gem 'aws-s3', :require => 'aws/s3'
gem 'carrierwave'
gem 'carrierwave_direct'
gem 'remotipart', '~> 0.4.1'
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
