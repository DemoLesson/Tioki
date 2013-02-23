class EduStatsController < ApplicationController
	layout 'edu_stats'

	def index

	end

	def create

		edu_stats = EduStats.new(params[:edu_stats])

		if edu_stats.save

			edu_stats[:total_students] = edu_stats[:yrs_teaching] * edu_stats[:avg_class_size] *edu_stats[:class_perday] 

			edu_stats[:total_hours_teaching] = edu_stats[:yrs_teaching] * 180 * 7.5

			session[:edu_stats] = edu_stats.id

		end

		respond_to do |format|
			if edu_stats.save
				format.html { redirect_to '/edu_stats/results', :notice => "Education details updated." }
			else
				format.html { redirect_to :back, :notice => "An error occurred."}
			end 
		end
	end

	def show

		@edu_stats = EduStats.find(session[:edu_stats])
	end 

end
