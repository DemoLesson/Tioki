class ExperiencesController < ApplicationController
	before_filter :login_required

	# Educations URL
  	def experiences_url; '/me/profile/edit/experiences'; end
	
	def index
		@experiences = self.current_user.experiences
		@experience = Experience.new
	end
	
	def edit
		@experience = Experience.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def create

		# Load old experience
		@experience = Experience.new(params[:experience])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]

		if @experience.save
			self.current_user.experiences << @experience
			
			flash[:success] = "Experience details updated."
			redirect_to :experiences
		else
			flash[:error] = "An error occurred."
			redirect_to :experiences
		end
	end
	
	def update

		# Load old experience
		@experience = Experience.find(params[:id])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]

		# Update the attributes
		@experience.update_attributes(params[:experience])
		
		if @experience.save
			flash[:success] = "Experience details updated."
			redirect_to :experiences
		else
			flash[:error] = "An error occurred."
			redirect_to :experiences
		end
	end
	
	# DELETE /experiences/1
	# DELETE /experiences/1.json
	def destroy
		@experience = Experience.find(params[:id])
		@experience.destroy

		respond_to do |format|
			format.html { redirect_to :experiences }
			format.json { head :ok }
		end
	end
end