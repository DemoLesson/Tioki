class ApplicationWizardController < ApplicationController
	layout 'wizard'

	helper_method :url

	def url; currentHost + '/wizards/application'; end
	def step1_url; url + '/step1'; end
	def step2_url; url + '/step2'; end
	def step3_url; url + '/step3'; end
	def step4_url; url + '/step4'; end
	def step5_url; url + '/step5'; end
	def step6_url; url + '/step6'; end
	def step7_url; url + '/step7'; end

	def index
		redirect_to :root if params[:job].nil?

		# Create a new application
		@app = Application.new
		@app.job_id = params[:job]

		# Let the user know if we have an issue creation the application record
		flash[:error] = "There was an error creating your application" unless @app.save

		# Add the application id to the session
		session[:application] = @app.id

		if User.current.nil?
			redirect_to :step1
		else
			@app.update_attribute(:user_id, User.current.id)
			redirect_to :step2
		end
	end

	def step1
		_loadSession

		if request.post?
			user = User.create(params[:user])

			session[:user] = User.authenticate(user.email, user.password)
			@app.update_attribute(:user_id, User.current.id)

			return redirect_to :step2
		end
	end

	def step2
		_loadSession

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
			user.experiences << exp
		end
	end

	def step3
		_loadSession

		if request.post?
			user = User.current

			if params[:education][:current]
				params[:education][:current] = true
			else
				params[:education][:current] = false
			end

			edu = Education.create(params[:education])
			user.educations << edu
		end
	end

	def step4
		_loadSession

		if request.post?
			user = User.current

			cred = Credential.create(params[:credential])
			user.credentials << cred
		end
	end

	def step5
		_loadSession

		if request.post?

			# Decide whether or not to show this on the profile
			if params[:profile]
				params[:asset][:assetType] = false
			else
				params[:asset][:assetType] = true
			end

			# Set the application id for the asset
			params[:asset][:application_id] = @app.id
			params[:asset][:user_id] = User.current.id

			# Yes I am taking this opportunity to name this var "ass"
			ass = Asset.create(params[:asset])
		end
	end

	def step6
		_loadSession

		@uploader = Video.new.video
		@uploader.success_action_redirect = new_video_url + '?redirect=' + url + '/step7&session=true'
	end

	def step7
		_loadSession

		unless session[:video].nil?
			@app.video_id = session[:video]
			@app.save
		end
	end

	def complete
		_loadSession

		if @app.update_attributes({:submitted => true, :status => 1, :viewed => 0})

			#Notify that owner(s) of the school that this application has been submitted
			job = Job.find(@app.job_id)
			UserMailer.teacher_applied(job.school_id, job.id, @app.user_id).deliver

			flash[:success] = "Your application has been submitted"
		else
			flash[:error] = "There was an issue submitting your application"
		end
		redirect_to :root
	end

	def _loadSession
		if session[:application].nil?

			# Let the user know if we have an issue creation the application record
			flash[:error] = "Unable to load the application in question."

			# Add the application id to the session
			redirect_to :root
		else

			# Load the application from session
			@app = Application.find(session[:application])
		end
	end

end
