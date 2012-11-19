class ApplicationWizardController < ApplicationController
	layout 'wizard'

	def url; '/wizards/application'; end
	def step2_url; url + '/step2'; end

	def step1
		if request.post?
			user = User.create(params[:user])
			session[:user] = User.authenticate(user.email, user.password)

			return redirect_to :step2
		end
	end

	def step2
		if request.post?
			user = User.current

			if params[:experience][:current]
				params[:experience][:current] = true
			else
				params[:experience][:current] = false
			end

			end_date = Time.strptime(params[:date][:end_date], "%m/%d/%Y")
			start_date = Time.strptime(params[:date][:start_date], "%m/%d/%Y")
			params[:experience][:startMonth] = start_date.strftime("%m")
			params[:experience][:startYear] = start_date.strftime("%Y")
			params[:experience][:endMonth] = end_date.strftime("%m")
			params[:experience][:endYear] = end_date.strftime("%Y")
			exp = Experience.create(params[:experience])
			user.teacher.experiences << exp
		end
	end

end
