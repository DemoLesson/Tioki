# HTTP Status Codes
module HTTPStatus
	class Unauthorized < StandardError
	end
	class NotFound < StandardError
	end
	class ServerError < StandardError
	end
end

# Application Controller
class ApplicationController < ActionController::Base
	protect_from_forgery

	# Exceptions and exception handler
	class SecurityTransgression < StandardError; end
  class ServerError < StandardError; end
  class NotFound < StandardError; end

  # Rescue all exceptions
	rescue_from Exception, :with => :rescue_action

	# Ensure permissions
	around_filter :ensure_permission_to_create, :only => [:new, :create]
	around_filter :ensure_permission_to_update, :only => [:edit, :update]
	around_filter :ensure_permission_to_destroy, :only => :destroy

	skip_before_filter :verify_authenticity_token
	before_filter :sweep_session
	before_filter :check_login_token
	# Helper methods
	helper_method :currentHost
	helper_method :currentPath
	helper_method :currentUser
	helper_method :currentURL

	# Current host / url / path methods
	# @todo make method names stricter: /[_a-z][_a-z0-9]*[!?=]?/
	def currentHost; request.protocol + request.host_with_port; end
	def currentURL; currentHost + currentPath; end
	def currentPath; request.fullpath; end;

	# Current User
	# @todo make method names stricter: /[_a-z][_a-z0-9]*[!?=]?/
	def currentUser
		begin
			@currentUser ||= User.find(session[:user])
		rescue
			User.new
		end
	end

	# Is "TIOKI" admin
	def require_admin
		return redirect_to :root, :notice => "Access Denied" if current_user.nil? || !current_user.is_admin
	end

	# Sweep away old sessions
	def sweep_session; Session.sweep("2 hours"); end

	# Require the user to login
	# @todo change to an around_filter
	def login_required
		return true if session[:user] && session[:user].is_a?(User)

		flash[:notice] = 'Please login to continue.'
		session[:return_to] = currentPath

		redirect_to :controller => "users", :action => "login"
	end

	def login_required_signup
		return true if session[:user] && session[:user].is_a?(User)
		redirect_to :controller => "welcome_wizard", :action => "step1"
	end

  # Check to see if a user is logged in and set session level args
  # @todo cleanup, streamline, and rename method
	def check_login_token

		# Bump updated_timestamp every page load
		_session = Session.where(:session_id => request.session_options[:id]).first
		
		unless _session.nil?

			# Set the user id on the session
			if session[:user].is_a?(User)
				_session.user_id = session[:user].id
			else
				_session.user_id = nil
			end

			# Update the timestamp
			_session.updated_at = Time.now.to_s(:db)
			_session.save
		end

		# HACK: Make this run on every page load.
		# If there is a referer set in the page url then
		# Save it to the session for use during registration
		# Or use to auto connect on sharing profiles
		self.check_if_referer

		# If there is no user session but we have login tokens go ahead and connect up the user to the session.
		if !session[:user] && cookies[:login_token_user]
			login_token = LoginToken.find_by_user_id_and_token_value(cookies[:login_token_user], cookies[:login_token_value])
			if login_token
				if login_token.expires_at >= Time.new
					session[:user] = User.find(login_token.user_id)
				else
					LoginToken.delete(login_token.id)
				end
			end
		end
	end

	# Check where the person may have been referred from
	# @todo rethink and fix this
	def check_if_referer

		# Check if we have a referer set anywhere
		if params.has_key?("_email_referer")
			session[:_referer] = params['_email_referer']
		end

		# Micro url referer
		if params.has_key?("_micro_referer")
			session[:_referer] = params['_micro_referer']
		end

		# Analytics key
		if params.has_key?("_ak")
			session[:_ak] = params['_ak']
		end
	end

	# Get the current user
	# @todo deprecate
	def current_user
		# Get the currently logged in user and set to Model Access
		@current_user ||= User.find(session[:user]) unless session[:user].nil?
	end

	def is_admin
		user = current_user
		!user.nil? && user.is_admin
	end

	# @todo deprecate?
	def redirect_to_stored
		if session[:return_to] != nil
			return_to = session[:return_to]
			session[:return_to] = nil
			redirect_to(return_to)
		elsif currentUser.new_record?
			redirect_to :controller => "users", :action => "login"
		elsif self.current_user != nil
			redirect_to :root
		end
	end

  # Log an analytic
  # @todo move to the analytic model
	def log_analytic(slug, message, tag = '', data = [], group = :root)

		# Make sure the slug group is a string
		slug = slug.to_s if slug.respond_to?('to_s')
		group = group.to_s if group.respond_to?('to_s')

		# If slug not a string error
		unless slug.is_a?(String)
			slug = "error"
			message = "Error saving analytic " + message
		end

		# Create new analytic
		a = Analytic.new

		# If the tag is a model then return the string tag
		tag = tag.tag! if tag.is_a?(ActiveRecord::Base)

		# If you want to connect a model
		a.tag = tag unless tag.nil? || !tag.is_a?(String)
		a.group = group unless group.nil? || !group.is_a?(String)
		a.message = message if tag.is_a?(String)
		a.slug = slug if tag.is_a?(String)
		a.data = YAML::dump(data)

		# Connect the request uri
		a.path = request.fullpath if request.fullpath.is_a?(String)

		# Link up the currently active user
		a.user = self.current_user unless currentUser.new_record?

		# Hook up the session
		a.session_id = request.session_options[:id]

		# Save the analytic
		a.save
	end

  # Get any analytics
  # @todo move to the analytic model
	def get_analytics(slug, tag = '', date_start = nil, date_end = nil, unique = false)

		# Make sure the slug is a string
		slug = slug.to_s if slug.respond_to?('to_s') unless slug.nil?
		# If slug is not a string raise an exception

		raise StandardError, "Slug is not a string" unless slug.is_a?(String) || slug.nil?

		# If the tag is a model then return the string tag
		tag = tag.tag! if tag.is_a?(ActiveRecord::Base)

		# Build the SQL Query string
		where = []
		where << "`slug` = '#{slug}'" unless slug.nil?
		where << "`tag` = '#{tag}'" unless tag.nil? || tag.empty?

		# Add a time constraint
		where << "`created_at` BETWEEN '#{date_start}' AND '#{date_end}'" unless date_start.nil? || date_end.nil? ||date_start.empty? || date_end.empty?

		# Concatinate the SQL Queries
		where = where.join(' AND ')

		# Find the matching analytics
		analytic = Analytic.where(where)

		# If unique users run a group by
		analytic = analytic.group('`user_id`') if unique

		# Yield to the block
		analytic = yield(analytic) if block_given?

		return analytic.respond_to?(:all) ? analytic.all : analytic
	end

	# Break MCV
	around_filter :__sessions_in_model

	# Append data to session
  # @todo rethink and revise
	before_filter :__session_append

	protected

		# Exceptions and error pages
		def rescue_action(e)

			# Log to GrayLog2
			log_exception(e)

			# Raise the error if in development
			raise e if Rails.env == 'development'

			# Makes sure the models are sourced
			__sessions_in_model do
				case e
				when SecurityTransgression, HTTPStatus::Unauthorized

					# Unauthorized
					@path = request.fullpath
					render :template => 'errors/error_401',
						:layout => 'layouts/application',
						:status => :forbidden
				when HTTPStatus::NotFound,
					ActionController::UnknownController,
					ActionController::UnknownAction,
					ActionController::RoutingError,
					ActiveRecord::RecordNotFound
					
					# 404s
					@not_found_path = request.fullpath
					render :template => 'errors/error_404',
						:layout => 'layouts/application',
						:status => 404
				else
					# If staging use pretty on all except fatals
					# raise e if Rails.env == 'staging'

					# Hide fatal errors on production
					@path = request.fullpath
					render :template => 'errors/error_500',
						:layout => 'layouts/application',
						:status => 500
				end
			end
		end

		# Security
		def ensure_permission_to_create
			return yield if is_admin

			class_name = self.class.name.gsub(/Controller$/,'').singularize
			if !Module.const_defined?(class_name) || currentUser.can_create?(class_name.constantize.new())
				yield
			else
				raise SecurityTransgression
			end
		end

		def ensure_permission_to_destroy
			return yield if is_admin

			class_name = self.class.name.gsub(/Controller$/,'').singularize
			if !Module.const_defined?(class_name) || currentUser.can_destroy?(class_name.constantize.find(params[:id]))
				yield
			else
				raise SecurityTransgression
			end
		end

		def ensure_permission_to_update
			return yield if is_admin

			class_name = self.class.name.gsub(/Controller$/,'').singularize
			if !params[:id] || !Module.const_defined?(class_name) || currentUser.can_update?(class_name.constantize.find(params[:id]))
				yield
			else
				raise SecurityTransgression
			end
		end

		# Break MCV
		def __sessions_in_model
			klasses = [ActiveRecord::Base, ActiveRecord::Base.class]
			methods = ["session", "cookies", "params", "request"]

			methods.each do |method|
				var = self.send(method)

				klasses.each do |klass|
					klass.send(:define_method, method, proc { var })
				end
			end

			yield

			methods.each do |method|      
				klasses.each do |klass|
					klass.send :remove_method, method
				end
			end
		end

	private

    # Add a hashed url var to the session
    # @todo append a url var to the session
		def __session_append
			return if params[:"--@"].nil?

			# Add session data
			session[:data] = Multimap.new if session[:data].nil?

			# Get the data and append it to the session
			Base64.decode64(params[:"--@"]).split(',').each do |data|
				key, val = data.split(':')

				if key == 'log_analytic'
					slug, ns = val.split('|')
					self.log_analytic(slug, 'URL Log Called', '', [], ns)
				else
					session[:data][key] = val
				end
			end
		end

    # Log an exception to graylog
		def log_exception(exception, severity = 4)

			# Log Error
			short = "#{exception.class} (#{exception.message})"

			error = String.new
			error << "\nURL: #{currentURL}"
			error << "\nReferer: #{request.referer rescue 'n/a'}"
			error << "\n" + short + "\n"
			error << "\n " + Rails.backtrace_cleaner.clean(exception.backtrace).join("\n ")

			file, line, method = exception.backtrace.first.split(':')
			method = method[4..-2]

			unless (defined? ::NOTIFY).nil?
				::NOTIFY.notify!(:short_message => short, :full_message => error, :level => severity, :file => file, :line => line, :method => method)
			else
				Rails.logger.error(error) if severity == 4
				Rails.logger.fatal(error) if severity == 3
			end
		end

    # Twitter oAuth access
    # @todo document
		def twitter_oauth
			#specifically set the authorize ath for authenticate in order
			#to only have to authorize once
			@consumer = OAuth::Consumer.new(APP_CONFIG.twitter.consumer_key, 
				APP_CONFIG.twitter.consumer_secret,
				{ :site => "http://api.twitter.com",
					:authorize_path => "/oauth/authenticate"
				})
		end

    # Facebook oAuth access
    # @todo document
		def facebook_oauth
			callback_url = "http://#{request.host_with_port}/facebook_callback"
			return Koala::Facebook::OAuth.new(APP_CONFIG.facebook.api_key, APP_CONFIG.facebook.app_secret, callback_url)
		end
end
