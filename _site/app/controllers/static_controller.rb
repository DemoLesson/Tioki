class StaticController < ApplicationController

	# Load in sub directory static/resources
	def _resources; render 'static/resources/' + params[:page]; end
end