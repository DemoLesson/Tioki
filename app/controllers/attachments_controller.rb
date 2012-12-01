class AttachmentsController < ApplicationController

	def index
        @user = User.current
        @asset = Asset.new
	end

	def create
		@user = User.current
		
		if @user.assets.create(params[:asset])
			flash[:success] = 'Attachment was successfully uploaded.'
		else
			flash[:success] = 'Attachement could not be uploaded.'
		end

		redirect_to :assets
	end

end