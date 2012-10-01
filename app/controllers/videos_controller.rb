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
		
		@teacher = false; unless params[:url].nil?

			# Get the teacher by url
			@teacher = Teacher.where('`url` = ?',params[:url]).first

			# Narrow the videos to only those attached to this teacher
			@videodb = @videodb.where('`teacher_id` = ?', @teacher.id)
		end

		# Get first video
		@video = @videodb.first
	end

	# GET /videos/1
	# GET /videos/1.xml
	def show
		# Get the teacher and teachers videos
		index

		# Url to video list
		videolist = request.url.split('/'); videolist.pop
		@videolist = videolist.join('/')

		# Get the video associated with the id
		@video = Video.find(params[:id])

		render :index
	end
	
	def myvideo
		@teacher = self.current_user.teacher
		if Video.find(:first, :conditions => ['teacher_id = ? AND is_snippet=?', @teacher.id, false], :order => 'created_at DESC').nil?
			@has_video = false
		else
			@has_video = true
		end
		
	end

	# GET /videos/new
	# GET /videos/new.xml
	def new

		if request.post? || !params[:key].nil?

			# Get the currently logged in teacher #!
			@teacher = self.current_user.teacher

			# Create a new video
			@video = Video.new
			@video.teacher = @teacher
			@video.secret_url = params[:key]
      		@video.video_id = params[:etag]

			if @video.save

				# Blank out the (deprecated) embed URLs
				@teacher.update_attribute(:video_embed_url, nil)
				@teacher.update_attribute(:video_embed_html, nil)

				# Encode the video
				@video.encode

				# Video status
				flash[:success] = "Your video was succesfully uploaded and is processing."
				return redirect_to :back
			end
		end

		# Get the variables for a Direct S3 upload
		@uploader = Video.new.video
		@uploader.success_action_redirect = new_video_url
	end

	# GET /videos/1/edit
	def edit
		@video = Video.find(params[:id])
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
				Whiteboard.createActivity(:video_upload, "{user.teacher.profile_link} uploaded a new video.", @video, {"video" => "zencoder"})

				if request.request_uri == "/card/"+self.current_user.teacher.url
					format.html { redirect_to "/card/"+self.current_user.teacher.url }
				else
					format.html { redirect_to(:root, :notice => 'Video was successfully uploaded.') }
					format.xml  { render :xml => @video, :status => :created }
				end
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
		video.teacher = self.current_user.teacher
		video.output_url = 'ext|' + embed
		video.video_id = embed

		begin
			# See if embed_code is valid
			Video.new.embed_code(nil, nil, 'ext|' + embed)

			# Try to save video
			if video.save

				# Let users know about the new video that was uploaded
				Whiteboard.createActivity(:video_upload, "{user.teacher.profile_link} linked a new video.", @teacher, {"video" => video.output_url})

				# Flash success and return
				flash[:success] = 'Video was successfully embeded.'
				return redirect_to :back
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
		@video.teacher_id = self.current_user.teacher.id
		@teacher = self.current_user.teacher
		@sourcevideo = Video.find(:first, :conditions => ['teacher_id = ? AND is_snippet=?', @teacher.id, false], :order => 'created_at DESC')
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
		@video.cleanup
		@video.destroy

		respond_to do |format|
			format.html { redirect_to(videos_url) }
			format.xml  { head :ok }
		end
	end
end
