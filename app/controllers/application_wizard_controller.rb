class ApplicationWizardController < ApplicationController
	layout 'wizard'

	def step1
		if request.post?
			dump params

			user = User.create(params[:user])
			
		end

	end

end
