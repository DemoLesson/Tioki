class EduStatsController < ApplicationController
	layout 'application'

	def index

	end

	def create

		edu_stats = EduStats.new(params[:edu_stats])

		if edu_stats.save
      
      #Calculating the Total Students served by the teacher
			edu_stats[:total_students] = edu_stats[:yrs_teaching] * edu_stats[:avg_class_size] *edu_stats[:class_perday] 

      #Calculating the Total Hours Teaching by the teacher
			edu_stats[:total_hours_teaching] = edu_stats[:yrs_teaching] * 867
      
      #Calculating the approximate size of their educator network
      # Determining based on their years teching, the number of times they have swithched schools. Assumed once every 6 years
      if  edu_stats[:yrs_teaching] < 7 
          
          edu_stats[:edu_network_public] = 33 + (5.3 * (edu_stats[:yrs_teaching] - 1))
          edu_stats[:edu_network_private] = 16 + (2.6 * (edu_stats[:yrs_teaching] - 1)) 
          edu_stats[:edu_network_charter] = 13 + (2.1 * (edu_stats[:yrs_teaching] - 1)) 
          edu_stats[:edu_network_catholic] = 20 + (3.2 * (edu_stats[:yrs_teaching] - 1)) 
        
      elsif edu_stats[:yrs_teaching] > 6 && edu_stats[:yrs_teaching] < 13 
        
          edu_stats[:edu_network_public] = (33 * 2) + (5.3 * (edu_stats[:yrs_teaching] - 2)) 
          edu_stats[:edu_network_private] = (16 * 2) + (2.6 * (edu_stats[:yrs_teaching] - 2)) 
          edu_stats[:edu_network_charter] = (13 * 2) + (2.1 * (edu_stats[:yrs_teaching] - 2)) 
          edu_stats[:edu_network_catholic] = (20 * 2) + (3.2 * (edu_stats[:yrs_teaching] - 2)) 
        
      elsif edu_stats[:yrs_teaching] > 12 && edu_stats[:yrs_teaching] < 19
          
          edu_stats[:edu_network_public] = (33 * 3) + (5.3 * (edu_stats[:yrs_teaching] - 3)) 
          edu_stats[:edu_network_private] = (16 * 3) + (2.6 * (edu_stats[:yrs_teaching] - 3)) 
          edu_stats[:edu_network_charter] = (13 * 3) + (2.1 * (edu_stats[:yrs_teaching] - 3)) 
          edu_stats[:edu_network_catholic] = (20 * 3) + (3.2 * (edu_stats[:yrs_teaching] - 3)) 
        
      elsif edu_stats[:yrs_teaching] > 18 && edu_stats[:yrs_teaching] < 25
          
          edu_stats[:edu_network_public] = (33 * 4) + (5.3 * (edu_stats[:yrs_teaching] - 4)) 
          edu_stats[:edu_network_private] = (16 * 4) + (2.6 * (edu_stats[:yrs_teaching] - 4)) 
          edu_stats[:edu_network_charter] = (13 * 4) + (2.1 * (edu_stats[:yrs_teaching] - 4)) 
          edu_stats[:edu_network_catholic] = (20 * 4) + (3.2 * (edu_stats[:yrs_teaching] - 4)) 
        
      elsif edu_stats[:yrs_teaching] > 24 && edu_stats[:yrs_teaching] < 31
        
          edu_stats[:educator_network_public] = (33 * 5) + (5.3 * (edu_stats[:yrs_teaching] - 5)) 
          edu_stats[:educator_network_private] = (16 * 5) + (2.6 * (edu_stats[:yrs_teaching] - 5)) 
          edu_stats[:educator_network_charter] = (13 * 5) + (2.1 * (edu_stats[:yrs_teaching] - 5)) 
          edu_stats[:educator_network_catholic] = (20 * 5) + (3.2 * (edu_stats[:yrs_teaching] - 5)) 
        
      elsif edu_stats[:yrs_teaching] > 30 && edu_stats[:yrs_teaching] < 37
        
          edu_stats[:educator_network_public] = (33 * 6) + (5.3 * (edu_stats[:yrs_teaching] - 6)) 
          edu_stats[:educator_network_private] = (16 * 6) + (2.6 * (edu_stats[:yrs_teaching] - 6)) 
          edu_stats[:educator_network_charter] = (13 * 6) + (2.1 * (edu_stats[:yrs_teaching] - 6)) 
          edu_stats[:educator_network_catholic] = (20 * 6) + (3.2 * (edu_stats[:yrs_teaching] - 6)) 
        
      elsif edu_stats[:yrs_teaching] > 36 && edu_stats[:yrs_teaching] < 43
        
          edu_stats[:educator_network_public] = (33 * 7) + (5.3 * (edu_stats[:yrs_teaching] - 7)) 
          edu_stats[:educator_network_private] = (16 * 7) + (2.6 * (edu_stats[:yrs_teaching] - 7)) 
          edu_stats[:educator_network_charter] = (13 * 7) + (2.1 * (edu_stats[:yrs_teaching] - 7)) 
          edu_stats[:educator_network_catholic] = (20 * 7) + (3.2 * (edu_stats[:yrs_teaching] - 7)) 
        
      elsif edu_stats[:yrs_teaching] > 42
        
          edu_stats[:educator_network_public] = (33 * 8) + (5.3 * (edu_stats[:yrs_teaching] - 8)) 
          edu_stats[:educator_network_private] = (16 * 8) + (2.6 * (edu_stats[:yrs_teaching] - 8)) 
          edu_stats[:educator_network_charter] = (13 * 8) + (2.1 * (edu_stats[:yrs_teaching] - 8)) 
          edu_stats[:educator_network_catholic] = (20 * 8) + (3.2 * (edu_stats[:yrs_teaching] - 8)) 
        
      end
      
			session[:edu_stats] = edu_stats.id

		end

		respond_to do |format|
			if edu_stats.save
				format.html { redirect_to '/impact/results', :notice => "Education details updated." }
			else
				format.html { redirect_to :back, :notice => "An error occurred."}
			end 
		end
	end

	def show

		@edu_stats = EduStats.find(session[:edu_stats])
	end 

end
