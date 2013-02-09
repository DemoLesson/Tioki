class AttachmentsController < ApplicationController
	before_filter :login_required

	def attachments_path; '/me/profile/edit/attachments'; end

	def index
        @user = User.current
        @asset = Asset.new
	end

	def destroy
		if Asset.find(params[:id]).destroy
			flash[:success] = 'Attachment was successfully deleted.'
		else
			flash[:error] = 'Attachment could not be deleted.'
		end

		redirect_to :attachments
	end

	def create
		@user = User.current
		
		if @user.assets.create(params[:asset])
			flash[:success] = 'Attachment was successfully uploaded.'
		else
			flash[:error] = 'Attachment could not be uploaded.'
		end

		redirect_to :attachments
	end

end
