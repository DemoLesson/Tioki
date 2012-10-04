class TechnologiesController < ApplicationController
  # GET /technologies
  # GET /technologies.json
  def index
    @technologies = Technology.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @technologies }
    end
  end

  def technology_list
	  @technologies = Technology.all
	  @stats = []
	  @stats.push({:name => 'Technologies', :value => Technology.count})
	  @stats.push({:name => 'Teachers Using', :value => TechnologyUser.count})
  end

  # GET /technologies/1
  # GET /technologies/1.json
  def show
    @technology = Technology.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/new
  # GET /technologies/new.json
  def new
    @technology = Technology.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @technology }
    end
  end

  # GET /technologies/1/edit
  def edit
    @technology = Technology.find(params[:id])
  end

  # POST /technologies
  # POST /technologies.json
  def create
    @technology = Technology.new(params[:technology])

    respond_to do |format|
      if @technology.save
        format.html { redirect_to "/technology_list", notice: 'Technology was successfully created.' }
        format.json { render json: @technology, status: :created, location: @technology }
      else
        format.html { render action: "new" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /technologies/1
  # PUT /technologies/1.json
  def update
    @technology = Technology.find(params[:id])

    respond_to do |format|
      if @technology.update_attributes(params[:technology])
        format.html { redirect_to "/technology_list", notice: 'Technology was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1
  # DELETE /technologies/1.json
  def destroy
    @technology = Technology.find(params[:id])
    @technology.destroy

    respond_to do |format|
      format.html { redirect_to technologies_url }
      format.json { head :ok }
    end
  end

  private
  def authenticate
  	return true if !self.current_user.nil? && self.current_user.is_admin
  
  	# If auth fail
  	render :text => "Access Denied"
  	return 401
  
  	# Block old HTTP Auth
  	#authenticate_or_request_with_http_basic do |id, password| 
  	#  id == USER_ID && password == PASSWORD
  	#end
  end
end
