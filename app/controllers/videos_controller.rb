class VideosController < ApplicationController
	protect_from_forgery :except => [:encode_notify]
	before_filter :login_required
	
	#REFACTOR
	# GET /videos
	# GET /videos.xml
	def index

		# Get all the videos
		@videodb = Video.where("'1' = '1'").order("`created_at` DESC")

		# Url to video list
		@videolist = request.url
		
		@user = nil
		unless params[:slug].nil?

			# Get the user by url
			@user = User.where('`slug` = ?', params[:slug]).first

			# Narrow the videos to only those attached to this user
			@videodb = @videodb.where('`user_id` = ?', @user.id)
		end

		# Get first video
		@video = @videodb.first

		@self = false
		if @user && @user.me?
			@self = true
		end
	end

	# GET /videos/1
	# GET /videos/1.xml
	def show
		# Get the user and users videos
		index

		# Url to video list
		videolist = request.url.split('/'); videolist.pop
		@videolist = videolist.join('/')

		# Get the video associated with the id
		@video = Video.find(params[:id])

		render :index
	end
	
	def myvideo
		@user = self.current_user
		@video = Video.find(params[:id])

		# Check to make sure the user is trying to edit their own video
		raise HTTPStatus::Unauthorized unless @video.user == @user || self.current_user.is_admin
	end

	# GET /videos/new
	# GET /videos/new.xml
	def new

		if request.post? || !params[:key].nil?

			# Create a new video
			@video = Video.new
			@video.user = User.current
			@video.secret_url = params[:key]
      		@video.video_id = params[:etag]

			if @video.save

				# Encode the video
				@video.encode

				if params[:session]
					session[:video] = @video.id
				end

				# Redirect to another location is requested
				if params[:redirect]
					return redirect_to params[:redirect]
				end

				# Video status
				flash[:success] = "Your video was succesfully uploaded and is processing."
				return redirect_to video_path(@video) + '/edit'
			end
		end

		# Get the variables for a Direct S3 upload
		@uploader = Video.new.video
		@uploader.success_action_redirect = new_video_url
	end

	# GET /videos/1/edit
	def edit
		@video = Video.find(params[:id])
		@existing_skills = video_path(@video) + '/skills'
		raise HTTPStatus::Unauthorized unless @video.user == self.current_user || self.current_user.is_admin
	end

	# Get Video Skills
	def skills
		@video = Video.find(params[:id])
		@skills = @video.skills

		@skills.collect! do |v|
			data = v.serializable_hash
			data["skill_group"] = v.skill_group.name.to_sym
			v = data
		end

		render :json => @skills
	end

	# POST /videos
	# POST /videos.xml
	def create
		@video = Video.new(params[:video])
		
		payload = params[:video][:location]
		#File.open(payload.tempfile)
		
		@config = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 's3.yml'))).result)[Rails.env]
		
		AWS::S3::Base.establish_connection!(
			 :access_key_id     => @config["access_key_id"],
			 :secret_access_key => @config["secret_access_key"]
		)
		
		AWS::S3::S3Object.store(payload.original_filename, open(payload.tempfile), 'DemoLessonVideo', :access => :public_read)
		
		respond_to do |format|
			if @video.save
				@video.encode

				# Let users know about the new video that was uploaded
				Whiteboard.createActivity(:video_upload, "{user.profile_link} uploaded a new video.", @video, {"video" => "zencoder"})

				format.html { redirect_to(:root, :notice => 'Video was successfully uploaded.') }
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => :root, :status => :unprocessable_entity }
			end
		end
	end
	
	def update_details
		
		respond_to do |format|
			if @video.save
				format.html { redirect_to(:root, :notice => 'Video was successfully uploaded.')}
			end
		end
	end

	# PUT /videos/1
	def update
		@video = Video.find(params[:id])

		@video.skills = []
		params[:skills].split(',').each do |skill|
			@video.skills << Skill.find(skill)
		end

		params[:video].each do |key, val|
			@video.send("#{key}=", val)
		end unless params[:video].nil? || params[:video].empty?

		if @video.save
			flash[:success] = 'Video was successfully updated.'
			redirect_to @video
		else
			render :action => "edit"
		end
	end

	def add_embed

		# Get the embed URL
		embed = params[:video_embed_url]

		# Mark the video as externel and upload
		video = Video.new
		video.output_url = 'ext|' + embed
		video.video_id = embed
		video.user = User.current

		begin
			# See if embed_code is valid
			Video.new.embed_code(nil, nil, 'ext|' + embed)

			# Try to save video
			if video.save

				# Let users know about the new video that was uploaded
				Whiteboard.createActivity(:video_upload, "{user.profile_link} linked a new video.", nil, {"video" => video.output_url})

				if params[:session]
					session[:video] = video.id
				end

				if params[:redirect]
					return redirect_to params[:redirect]
				end

				# Flash success and return
				flash[:success] = 'Video was successfully embeded.'
				return redirect_to video_path(video) + '/edit'
			end
			
			raise StandardError, 1
		rescue => e

			# Flash error and return
			flash[:error] = 'Video could not be embeded, make sure you are using a valid url.'
			return redirect_to :back
		end
	end

	def create_snippet
		@timestring = params[:date][:hour].to_s+":"+params[:date][:minute].to_s+":"+params[:date][:second].to_s+".0"
		@video = Video.new
		@video.user = self.current_user
		@user = self.current_user
		@sourcevideo = Video.where('user_id = ? AND is_snippet=?', @user.id, false).order('created_at DESC').first
		@video.secret_url = @sourcevideo.secret_url
		@video.video_id = @sourcevideo.video_id
		@video.is_snippet = true
		respond_to do |format|
			if @video.save
				@video.snippet_encode(@timestring)
				format.html { redirect_to :back, :notice => "Your snippet has been created and is currently encoding." }
			end
		end
	end

	# DELETE /videos/1
	# DELETE /videos/1.xml
	def destroy
		@video = Video.find(params[:id])
		@user = @video.user
		@video.cleanup
		@video.destroy

		respond_to do |format|
			if URI(request.referrer).path.start_with?('/videos')
				format.html { redirect_to "/videos" }
			else
				format.html { redirect_to "/profile/#{@user.slug}/videos" }
			end
			format.xml { head :ok }
		end
	end

	def admin
		raise HTTPStatus::Unauthorized unless self.current_user.is_admin

		@stats = Array.new
		@stats << {:name => "All Videos", :value => Video.count}
		@stats << {:name => "Remote Videos", :value => Video.where("`videos`.`output_url` LIKE 'ext|%'").count}
		@stats << {:name => "Local Videos", :value => Video.where("`videos`.`output_url` NOT LIKE 'ext|%'").count}

		@videos = Video.paginate(:page => params[:page], :per_page => 20)

		unless params[:order].empty?
			col, dir = params[:order].split('-')
			@videos = @videos.order("`videos`.`#{col}` #{dir}")
		else
			@videos = @videos.order("`videos`.`created_at` DESC")
		end

		unless params[:name].empty?
			@videos = @videos.where("`videos`.`name` LIKE '%#{params[:name]}%'")
		end

		unless params[:user].empty?
			@videos = @videos.joins("LEFT JOIN `users` ON `videos`.`user_id` = `users`.`id`")
			@videos = @videos.where("`users`.`name` LIKE '%#{params[:user]}%'")
		end

		unless params[:local].empty?
			@videos = @videos.where("`videos`.`output_url` LIKE 'ext|%'")
		end
	end
end
