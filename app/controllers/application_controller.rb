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
	#filter_parameter_logging "password"
	#filter_parameter_logging "password_confirmation"
	skip_before_filter :verify_authenticity_token
	before_filter :check_login_token
	#layout 'application'

	protect_from_forgery
	def login_required
		if session[:user]
			return true
		end
		flash[:notice]='Please login to continue'
		session[:return_to] = request.path
		redirect_to :controller => "users", :action => "login"
		return false
	end

	def teacher_required
		if self.current_user.teacher
			return true
		else
			flash[:notice] = 'Must be using a teacher account to access'
			redirect_to :root
			return false
		end
	end

	def check_login_token

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

	def check_if_referer
		
		flash[:tioki_message] = "<a target =\"_blank\" href=\"http://blog.tioki.com/student-blogging\" style=\"color:#fff\">Today's Featured Event: EdTech Made Easy</a>".html_safe
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

	def current_user

		# Get the currently logged in user and set to Model Access
		User.find(session[:user]) unless session[:user].nil?
	end
	
	def is_admin
	end
	
	def belongs_to_me
	end

	def redirect_to_stored
		if session[:return_to] != nil
			return_to = session[:return_to]
			session[:return_to] = nil
			redirect_to(return_to)
		elsif self.current_user.nil?
			redirect_to :controller => "users", :action => "login"
		#elsif self.current_user.default_home.present?
		#  redirect_to(current_user.default_home)
		elsif self.current_user.teacher != nil
			redirect_to :root
		elsif self.current_user.school != nil || self.current_user.is_shared == true
			redirect_to :root
		else
			#dont_choose_stored
			#redirect_to :controller=>'users', :action=>'choose_stored'
		end
	end

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
		a.user = self.current_user unless self.current_user.nil?

		# Hook up the session
		a.session_id = request.session_options[:id]

		# Save the analytic
		a.save
	end

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

	##################
	# Error Handling #
	##################

	if !Preview::Application.config.consider_all_requests_local || ENV['RAILS_ENV'] == 'staging'

		# Server Error
		rescue_from Exception, with: :render_500
		rescue_from HTTPStatus::ServerError, with: :render_500

		# Unauthorized
		rescue_from HTTPStatus::Unauthorized, with: :render_401

		# Not Found
		rescue_from HTTPStatus::NotFound, with: :render_404
		rescue_from ActionController::RoutingError, with: :render_404
		rescue_from ActionController::UnknownController, with: :render_404
		rescue_from ActionController::UnknownAction, with: :render_404
		rescue_from ActiveRecord::RecordNotFound, with: :render_404
	end

	# Break MCV	
	around_filter :__sessions_in_model

	# Append data to session
	before_filter :__session_append

	protected

		# Break MCV
		# => Though Controversial to many programmers MCV programming while
		# still a standard is actually quite limiting to the capabilities of the developer.
		# This breaks the MCV shell and turns the code into a modern age framework where all
		# for models happen on the models
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

		def render_401(exception)
			
			# Log Error
			log_exception(exception)

			# Path that was not found
			@path = request.fullpath
			render template: 'errors/error_401', layout: 'layouts/application', status: 401
		end

		def render_404(exception)
			
			# Log Error
			log_exception(exception)

			# Path that was not found
			@not_found_path = request.fullpath
			render template: 'errors/error_404', layout: 'layouts/application', status: 404
		end

		def render_500(exception)

			# Log Error
			log_exception(exception)
			render template: 'errors/error_500', layout: 'layouts/application', status: 500
		end

		def log_exception(exception, severity = 4)

			# Log Error
			short = "#{exception.class} (#{exception.message})"

			error = String.new
			error << "\nURL: #{request.fullpath}"
			error << "\n" + short + "\n"
			error << "\n " + Rails.backtrace_cleaner.clean(exception.backtrace).join("\n ")

			file, line, method = exception.backtrace.first.split(':')
			method = method [4..-2]

			unless NOTIFY.nil?
				NOTIFY.notify!(:short_message => short, :full_message => error, :level => severity, :file => file, :line => line, :method => method)
			else
				Rails.logger.error(error) if severity == 4
				Rails.logger.fatal(error) if severity == 3
			end
		end

		def twitter_oauth
			#specifically set the authorize ath for authenticate in order
			#to only have to authorize once
			@consumer = OAuth::Consumer.new(APP_CONFIG.twitter.consumer_key, 
																			APP_CONFIG.twitter.consumer_secret, 
																			{ :site => "http://twitter.com", 
																				:authorize_path => "/oauth/authenticate" 
																			}
																		 )
		end

		def facebook_oauth
			callback_url = "http://#{request.host_with_port}/facebook_callback"
			return Koala::Facebook::OAuth.new(APP_CONFIG.facebook.api_key, APP_CONFIG.facebook.app_secret, callback_url)
		end
end
