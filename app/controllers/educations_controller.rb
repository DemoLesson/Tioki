class EducationsController < ApplicationController
  before_filter :login_required
  
    def education
		@teacher = User.find(self.current_user.id)
		raise ActiveRecord::RecordNotFound, "Teacher not found." if @user.nil?
	end
	
	def remove_education
		@education = Education.find_by_id(params[:id], :limit => 1)
		@education.destroy

		unless params[:redirect].nil?
			return redirect_to params[:redirect]
		end
		
		respond_to do |format|
			format.html { redirect_to :education }
		end
	end
	
	def edit_education
		@education = Education.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def update_education
		@teacher = User.find(self.current_user.id)
		@teacher.educations.build(params[:education])
		
		respond_to do |format|
			if @teacher.save
				format.html { redirect_to :education, :notice => "Education details updated." }
			else
				format.html { redirect_to :education, :notice => "An error occurred."}
			end 
		end
	end
	
	def update_existing_education
		@education = Education.find(params[:id])
		
		respond_to do |format|
			if @education.update_attributes(params[:education])
				format.html { redirect_to :education, :notice => "Education details updated." }
			else
				format.html { redirect_to :education, :notice => "An error occurred."}
			end 
		end
	end
    
end