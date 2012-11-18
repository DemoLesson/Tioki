class ApplicationWizardController < ApplicationController
	layout 'wizard'

	def url; '/wizards/application'; end
	def step2_url; url + '/step2'; end

	def step1
		if request.post?
			dump params

			user = User.create(params[:user])
			session[:user] = User.authenticate(user.email, user.password)

			return redirect_to :step2
		end
	end

end
