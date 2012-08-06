class EventsController < ApplicationController
  layout 'standard', :except => [:list]

  # GET /events
  # GET /events.json
  def index
    # Filtered Events
    @events = Event.all
    # Unfiltered Events
    @_events = Event.all
    # Topics
    @topics = Eventtopic.all

    @events.select! do |x|
      (x.end_time.future? || x.end_time.today?) && x.published
    end

    #print params.inspect;
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def list
    @events = Event.all

    # Only show published events
    unless params.has_key?("mine")
      @events.select! do |x|
        x.published
      end
    end

    # Show only events on a specific date
    if params.has_key?("date")
      @events = @events.select do |v|
        v.start_time.to_datetime.strftime("%m/%d/%Y") == params['date']
      end
    end

    # Show only events in the future
    if params.has_key?("future")
      @events.select! do |x|
        x.end_time.future? || x.end_time.today?
      end
    end

    # Handle search queries
    if params.has_key?("search")
      @events.select! do |x|
        x.name.downcase.include?(params['search'].downcase) || x.description.downcase.include?(params['search'].downcase)
      end
    end

    # Handle filtering by topics
    if params.has_key?("topic")
      @events.select! do |x|
        topic_exists = false
        x.eventtopics.each do |t|
          topic_exists = t.name == params['topic']
          break if topic_exists
        end

        topic_exists
      end
    end

    if params.has_key?("mine")
      @events.select! do |x|
        x.user == self.current_user
      end
    end

    respond_to do |format|
      format.html { render :action => "index" }
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    # When a new event is created we do not want to publish it by default
    @event.published = false

    # Link up the event format
    if params.has_key?("eventformat")
      @event.eventformats = []
      @event.eventformats << Eventformat.find(params['eventformat'])
    end

    # Link up the topics that will be covered at this event
    if params.has_key?("eventtopic")
      params['eventtopic'].each do |topic|
        @event.eventtopics = []
        @event.eventtopics << Eventtopic.find(topic)
      end
    end

    if params.has_key?("event")
      # Set the time properly
      if params['event'].has_key?("start_time") && !params['event']['start_time'].empty?
        date = DateTime.strptime(params['event']['start_time'], "%m/%d/%Y %l:%M %P")
        @event.start_time = date
      end

      # Set the time properly
      if params['event'].has_key?("end_time") && !params['event']['end_time'].empty?
        date = DateTime.strptime(params['event']['end_time'], "%m/%d/%Y %l:%M %P")
        @event.start_time = date
      end

      # Set the time properly
      if params['event'].has_key?("rsvp_deadline") && !params['event']['rsvp_deadline'].empty?
        date = DateTime.strptime(params['event']['rsvp_deadline'], "%m/%d/%Y %l:%M %P")
        @event.rsvp_deadline = date
      end

      # Get the address into a geolocatable string
      address = ''
      address << params['event']['loc_address'] if params['event'].has_key?("loc_address")
      address << ' ' + params['event']['loc_address1'] if params['event'].has_key?("loc_address1")
      address << ', ' + params['event']['loc_city'] if params['event'].has_key?("loc_city")
      address << ', ' + params['event']['loc_state'] if params['event'].has_key?("loc_state")

      unless address.empty?
        begin
          latlon = Geocoder.search(address)[0].geometry['location']
          @event.loc_latitude = latlon['lat']
          @event.loc_longitude = latlon['lng']
        rescue NoMethodError
        end
      end
    end

    # Apply the current user as the owner
    @event.user = self.current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    # Link up the event format
    if params.has_key?("eventformat")
      @event.eventformats = []
      @event.eventformats << Eventformat.find(params['eventformat'])
    end

    # Link up the topics that will be covered at this event
    if params.has_key?("eventtopic")
      @event.eventtopics = []
      params['eventtopic'].each do |topic|
        @event.eventtopics << Eventtopic.find(topic)
      end
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end

  # Admin Pane for Events
  def admin_events
    @events = Event.all
    @published = Event.all.select!{|x| x.published}
    @pending = Event.all.select!{|x| !x.published}

    # Get events stats
    @stats = []
    @stats.push({:name => 'Total Events', :value => @events.count})
    @stats.push({:name => 'Published Events', :value => @published.count})
    @stats.push({:name => 'Pending Events', :value => @pending.count})

    # Prepare pagination
    @events = @events.paginate :page => params[:page], :per_page => 100
    @published = @published.paginate :page => params[:page], :per_page => 100
    @pending = @pending.paginate :page => params[:page], :per_page => 100
  end
end
