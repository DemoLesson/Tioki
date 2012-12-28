class EducationsController < ApplicationController
  before_filter :login_required

  	# Educations URL
  	def educations_url; '/me/profile/edit/educations'; end
  
    def index
		@educations = self.current_user.educations

		@education = Education.new
		raise ActiveRecord::RecordNotFound, "User not found." if currentUser.new_record?
	end
	
	def destroy
		@education = Education.find_by_id(params[:id], :limit => 1)
		@education.destroy

		unless params[:redirect].nil?
			return redirect_to params[:redirect]
		end
		
		respond_to do |format|
			format.html { redirect_to :educations }
		end
	end
	
	def edit
		@education = Education.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def create
		@user = self.current_user
		education = @user.educations.build(params[:education])
		
		respond_to do |format|
			if education.save
				format.html { redirect_to :educations, :notice => "Education details updated." }
			else
				format.html { redirect_to :educations, :notice => "An error occurred."}
			end 
		end
	end
	
	def update
		@education = Education.find(params[:id])
		
		if @education.update_attributes(params[:education])
			redirect_to :educations, :notice => "Education details updated." 
		else
			redirect_to :educations, :notice => "An error occurred."
		end 
	end
end
