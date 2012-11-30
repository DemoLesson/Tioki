class AttachmentsController < ApplicationController
        # Attachments
	#REFACTOR

	def attach
		@teacher = Teacher.find_by_id(self.current_user.teacher.id)
		@teacher.new_asset_attributes=params[:asset]

		respond_to do |format|
			if @teacher.save_assets
				format.html { redirect_to(@teacher, :notice => 'Attachment was successfully uploaded.') }
				format.json  { render :json => @teacher, :status => :created, :location => @teacher }
			else
				format.html { render :action => "new" }
				format.json  { render :json => @teacher.errors, :status => :unprocessable_entity }
			end
		end
	end
	
	def purge
		@teacher = Teacher.find_by_id(self.current_user.teacher.id)
		@asset = Asset.find_by_id(params[:id])
		if @asset.teacher_id == User.current.teacher.id
			@asset.destroy

			unless params[:redirect].nil?
				return redirect_to params[:redirect]
			end
		
			respond_to do |format|
			 format.html { redirect_to(:back, :notice => 'Attachment removed.') }
			 format.xml  { head :ok }
	
		@teacher = Teacher.find(params[:teacher_id])
		
		respond_to do |format|
			format.html { redirect_to "/"+@teacher.url }
		end
	end

	def appattachments
		@application = Application.find(params[:id])
		@teacher = Teacher.find(self.current_user.teacher.id)
	end

	def profileattachments
        @teacher = User.current.teacher
	end
end