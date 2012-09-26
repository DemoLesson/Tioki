class VideosController < ApplicationController
	protect_from_forgery :except => [:encode_notify]
	before_filter :login_required
	
	#REFACTOR
	# GET /videos
	# GET /videos.xml
	def index
		@videodb = Video.where("'1' = '1'").order("`created_at` DESC")
	end

	# GET /videos/1
	# GET /videos/1.xml
	def show
		@video = Video.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml  { render :xml => @video }
		end
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

		if request.post?

			# Get the currently logged in teacher #!
			@teacher = self.current_user.teacher

			# Check for a video
			#if Video.where("`teacher_id` = ? && `is_snippet` = ?", @teacher.id, false).order("`created_at` DESC").first.nil?
			#	@has_video = false
			#else
			#	@has_video = true
			#end

			# Create a new video
			@video = Video.new

			@video.teacher = @teacher
			@video.video = params[:video]

			@video.secret_url = "key"
			@video.video_id = "id"

			#dump @video.inspect

			if @video.save

				# Blank out the (deprecated) embed URLs
				@teacher.update_attribute(:video_embed_url, nil)
				@teacher.update_attribute(:video_embed_html, nil)

				# Encode the video
				#@video.encode

				# Video status
				flash[:success] = "Your video was succesfully uploaded and is processing."
				return render :text => "done"
			end
		end

		#@uploader = Video.new.video
		#@uploader.success_action_redirect = new_video_url
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
	# PUT /videos/1.xml
	def update
		@video = Video.find(params[:id])

		respond_to do |format|
			if @video.update_attributes(params[:video])
				format.html { redirect_to(@video, :notice => 'Video was successfully updated.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @video.errors, :status => :unprocessable_entity }
			end
		end
	end

	def add_embed
		@teacher = Teacher.find(:first, :conditions => ["user_id = ?", self.current_user.id])
		@teacher.video_embed_url = params[:video_embed_url]
		response = HTTParty.get "http://noembed.com/embed", { :query => { :url => params[:video_embed_url], :maxwidth => '640', :maxheight => '500' } }
		json = JSON.parse response.body
		@teacher.video_embed_html = json['html']
		if @teacher.video_embed_html
			@teacher.save

			# Let users know about the new video that was uploaded
			Whiteboard.createActivity(:video_upload, "{user.teacher.profile_link} linked a new video.", @teacher, {"video" => @teacher.video_embed_url})

			redirect_to :back, :notice => 'Video was successfully embeded.'
		else
			redirect_to :back, :notice => 'Video could not be embeded, make sure you are using a valid url.'
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
		@video.destroy

		respond_to do |format|
			format.html { redirect_to(videos_url) }
			format.xml  { head :ok }
		end
	end
end
