class ApplicationWizardController < ApplicationController
	layout 'wizard'

	helper_method :url

	def url; currentHost + '/wizards/application'; end
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

	def step3
		if request.post?
			user = User.current

			if params[:education][:current]
				params[:education][:current] = true
			else
				params[:education][:current] = false
			end

			edu = Education.create(params[:education])
			user.teacher.educations << edu
		end
	end

	def step4
		if request.post?
			user = User.current

			cred = Credential.create(params[:credential])
			user.teacher.credentials << cred
		end
	end

	def step5
		if session[:application].nil?

			# Create a new application
			@app = Application.new
			@app.teacher_id = User.current.teacher.id
			@app.job_id = session[:job] || 1

			# Let the user know if we have an issue creation the application record
			flash[:error] = "There was an error creating your application" unless @app.save

			# Add the application id to the session
			session[:application] = @app.id
		else

			# Load the application from session
			@app = Application.find(session[:application])
		end

		if request.post?

			# Decide whether or not to show this on the profile
			if params[:profile]
				params[:asset][:assetType] = false
			else
				params[:asset][:assetType] = true
			end

			# Set the application id for the asset
			params[:asset][:application_id] = @app.id
			params[:asset][:teacher_id] = User.current.teacher.id

			# Yes I am taking this opportunity to name this var "ass"
			ass = Asset.create(params[:asset])
		end
	end

	def step6
		@uploader = Video.new.video
		@uploader.success_action_redirect = new_video_url + '?redirect=' + url + '/step7'
	end

end
