class JobPacksController < ApplicationController
	before_filter :source_owner

	def index
		@jobpacks = @group.job_packs
	end

	def new
		@jobpack = JobPack.new
	end

	def create
	end

	protected

		def source_owner
			@group = Group.find(params[:group_id])
		end
end