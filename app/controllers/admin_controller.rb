class AdminController < ApplicationController
	around_filter :check_for_admin
	layout 'admin'

	def index
		# Get a list of all the stats
		@stats = _getStats

		# Get the length of the biggest stat
		@id_size = @stats.values.max.to_s.length
	end

	def users
		# This is for styling purposes
		@id_size = User.limit(1).order('id DESC').first.id.to_s.length

		# Load every user in our platform
		users = User.unscoped.order('last_login DESC')

		# Clean the parameters
		params.clean!

		# Filter the users down
		if params[:search]
			if params[:search][:text]
				search = '%' + params[:search][:text] + '%'
				users = users.where('users.name LIKE ? OR users.email LIKE ?', search, search)
			end

			users = users.joins(:applications).where('users.id = applications.user_id AND applications.submitted = ?', true).group('users.id') if params[:search][:applications]
			users = users.joins(:videos).where('users.id = videos.user_id').group('users.id') if params[:search][:videos]
		end

		# Paginate the users list
		@users = users.paginate(:per_page => 20, :page => params[:page])
	end

	private

		def check_for_admin
			if currentUser.is_admin
				yield
			else
				raise SecurityTransgression
			end
		end

		def _getStats
			db = ActiveRecord::Base.connection
			stats = Hash.new

			# User info
			stats[:users]						= db.execute("SELECT COUNT(*) as 'count' FROM `users`").to_a.first.first
			stats[:connections]					= db.execute("SELECT COUNT(*) as 'count' FROM `connections` WHERE `pending` = '0'").to_a.first.first
			stats[:pending_connections]			= db.execute("SELECT COUNT(*) as 'count' FROM `connections` WHERE `pending` = '1'").to_a.first.first
			stats[:videos]						= db.execute("SELECT COUNT(*) as 'count' FROM `videos`").to_a.first.first
			stats[:total_vouches]				= db.execute("SELECT COUNT(*) as 'count' FROM `vouches`").to_a.first.first
			
			# Events
			stats[:published_events]			= db.execute("SELECT COUNT(*) as 'count' FROM `events`").to_a.first.first

			# Groups and Orgs
			stats[:groups]						= db.execute("SELECT COUNT(*) as 'count' FROM `groups` WHERE POW(2, 3) & `permissions` <= 0").to_a.first.first
			stats[:organizations]				= db.execute("SELECT COUNT(*) as 'count' FROM `groups` WHERE POW(2, 3) & `permissions` > 0").to_a.first.first

			# Jobs
			stats[:jobs]						= db.execute("SELECT COUNT(*) as 'count' FROM `jobs`").to_a.first.first
			stats[:running_jobs]				= db.execute("SELECT COUNT(*) as 'count' FROM `jobs` WHERE `status` = 'running'").to_a.first.first
			stats[:completed_jobs]				= db.execute("SELECT COUNT(*) as 'count' FROM `jobs` WHERE `status` = 'completed'").to_a.first.first
			stats[:reviewed_job_applications]	= db.execute("SELECT COUNT(*) as 'count' FROM `applications` WHERE `status` != 'Not Reviewed'").to_a.first.first
			stats[:unreviewed_job_applications]	= db.execute("SELECT COUNT(*) as 'count' FROM `applications` WHERE `viewed` = 'Not Reviewed'").to_a.first.first
			stats[:interviews]					= db.execute("SELECT COUNT(*) as 'count' FROM `interviews`").to_a.first.first
			
			return stats
		end

end