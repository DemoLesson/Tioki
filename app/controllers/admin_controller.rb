class AdminController < ApplicationController
	around_filter :check_for_admin
	layout 'admin'

	def index
		@stats = _getStats
	end

	def users
		@users = User.unscoped
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