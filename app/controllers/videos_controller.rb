class VideosController < ApplicationController
  #REFACTOR
  # GET /videos
  # GET /videos.xml
  def index
    @videodb = Video.all
    
    @config = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'viddler.yml'))).result)[Rails.env]
    
    viddler = Viddler::Client.new(@config["api_token"])
    viddler.authenticate! @config["login"], @config["password"]
    
    @videos = viddler.get 'viddler.videos.getByUser', :user => @config["login"]
    puts @videos
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @videodb }
    end
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

  # GET /videos/new
  # GET /videos/new.xml
  def new
    @video = Video.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @video }
    end
  end

  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])
  end

  # POST /videos
  # POST /videos.xml
  def create
    @video = Video.find_by_teacher_id(self.current_user.teacher.id)
    if @video == nil
      @video = Video.new(params[:video])
    end
    
    @video.teacher_id = self.current_user.teacher.id
    @config = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'viddler.yml'))).result)[Rails.env]
    
    #puts @config
    
    uploadHash = params[:video][:location]
    
    #puts @uploadHash
    
    viddler = Viddler::Client.new(@config["api_token"])
    viddler.authenticate! @config["login"], @config["password"]
    
    new_video = viddler.upload(File.open(uploadHash.tempfile), {
      :title       => self.current_user.name,
      :description => 'Demo Lesson',
      :tags        => 'demolesson',
      :make_public => 0
    })
    
    puts new_video
    
    @video.video_id = new_video["video"]["id"]
    @video.secret_url = nil
       
    respond_to do |format|
       if @video.save
         format.html { redirect_to(:root, :notice => 'Video was successfully uploaded.') }
         format.xml  { render :xml => @video, :status => :created }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => :root, :status => :unprocessable_entity }
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

  def record
    @video = Video.find_by_teacher_id(self.current_user.teacher.id)
    if @video == nil
      @video = Video.new(params[:video])
    end
    
    @config = YAML::load(ERB.new(IO.read(File.join(Rails.root.to_s, 'config', 'viddler.yml'))).result)[Rails.env]
    viddler = Viddler::Client.new(@config["api_token"])
    viddler.authenticate! @config["login"], @config["password"]
    
    @recordToken = viddler.get 'viddler.videos.getRecordToken'
    puts @recordToken
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
