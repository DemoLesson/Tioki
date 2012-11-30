class ExperiencesController < ApplicationController
    before_filter :login_required
    
    def index
    	@experiences = self.current_user.experiences
	end
	
	def edit
		@experience = Experience.find(params[:id])
		
		respond_to do |format|
			format.html
		end
	end
	
	def create
		@experience = Experience.new(params[:experience])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]
		if params[:current]
		  @experience.current=true
		else
		  @experience.current=false
		end
		
		self.current_user.experiences.build(:company => @experience.company, 
                                            :position => @experience.position, 
                                            :description => @experience.description, 
                                            :startMonth => @experience.startMonth, 
                                            :startYear => @experience.startYear, 
                                            :endMonth => @experience.endMonth, 
                                            :endYear => @experience.endYear, 
                                            :current => @experience.current)
		
		respond_to do |format|
			if @user.save
				format.html { redirect_to :experience, :notice => "Experience details updated." }
			else
				format.html { redirect_to :experience, :notice => "An error occurred."}
			end 
		end
	end
	
	def update
		@prev_experience = Experience.find(params[:id])
		
		@experience = Experience.new(params[:experience])
		@experience.startMonth = params[:date][:startMonth]
		@experience.startYear = params[:date][:startYear]
		@experience.endMonth = params[:date][:endMonth]
		@experience.endYear = params[:date][:endYear]
				if params[:current]
			        @experience.current=true
				else
			        @experience.current=false
				end
		
		respond_to do |format|
			if @prev_experience.update_attributes(:company => @experience.company, :position => @experience.position, :description => @experience.description, :startMonth => @experience.startMonth, :startYear => @experience.startYear, :endMonth => @experience.endMonth, :endYear => @experience.endYear, :current => @experience.current)
				format.html { redirect_to :experience, :notice => "Experience details updated." }
			else
				format.html { redirect_to :experience, :notice => "An error occurred."}
			end 
		end
	end
    
    # DELETE /experiences/1
    # DELETE /experiences/1.json
    def destroy
        @experience = Experience.find(params[:id])
        @experience.destroy

        respond_to do |format|
            format.html { redirect_to presentations_url }
            format.json { head :ok }
        end
    end
end