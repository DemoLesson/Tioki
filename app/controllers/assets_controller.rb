class AssetsController < ApplicationController
	def destroy
		if Asset.find(params[:id]).destroy
			flash[:success] = 'Attachment was successfully deleted.'
		else
			flash[:error] = 'Attachment could not be deleted.'
		end

		redirect_to :attachments
	end
end
