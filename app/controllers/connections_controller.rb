require 'mail'
class ConnectionsController < ApplicationController
  before_filter :login_required

  # GET /connections
  # GET /connections.json
  def index
    if params[:connectsearch]
      @connections = Teacher.search(params[:connectsearch]).paginate(:per_page => 25, :page => params[:page])
    else
      @connections = Teacher.paginate(:page=> params[:page], :per_page => 25)
    end
    @my_connections = Connection.find_for_user(self.current_user.id).collect(&:user_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @connections }
    end
  end

  def add_connection(respond = true)
    # Check and see if we are already connected
    @previous = Connection.find(:first, :conditions => ['owned_by = ? AND user_id = ?', self.current_user.id, params[:user_id]])

    # If we are not go ahead and initiate the connection
    if @previous == nil

      # Create the connection
      @connection = Connection.new
      @connection.owned_by = self.current_user.id
      @connection.user_id = params[:user_id]

      # If everything saved ok
      if @connection.save
        # Notify the other user of my connection request
        UserMailer.userconnect(self.current_user.id, params[:user_id]).deliver

        # If respond is set to true then lets redirect
        if respond

          # Redirect to "My Connections"
          respond_to do |format|
            format.html { redirect_to :pending_connections }
          end
        end
      end

    # Whoops we're already connected
    else

      # If respond is set to true then lets redirect
      if respond

        # Redirect to "My Connections"
        respond_to do |format|
          format.html { redirect_to :my_connections }
        end
      end
    end
  end

  def remove_connection
    @connection = Connection.find(:first, :conditions => ['owned_by = ? and user_id = ?', self.current_user.id ,params[:user_id]])
    @oconnection = Connection.find(:first, :conditions => ['owned_by = ? and user_id = ?', params[:user_id], self.current_user.id])
    @connection.destroy
    if @oconnection != nil
      @oconnection.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to :my_connections }
    end
  end

  def remove_pending
    @connection = Connection.find(:first, :conditions => ['owned_by = ? and user_id = ? and pending = true', params[:user_id], self.current_user.id])
    @connection.destroy
    
    respond_to do |format|
      format.html { redirect_to :pending_connections }
    end
  end

  def accept_connection
    # Get the connection in question (A -> B)
    @connect= Connection.find(:first, :conditions => ['owned_by = ? and user_id = ?', params[:user_id], self.current_user.id])

    # Make the connection no longer pending
    @connect.pending = false

    # If the connection saves
    if @connect.save

      # Create a second connection from point (B -> A)
      @connection = Connection.new

      # Add the current user and the owner
      @connection.owned_by=self.current_user.id
      @connection.user_id=params[:user_id]

      # Since were accepting the original connection don't make this pending
      @connection.pending=false

      # Save this connection
      if @connection.save
        #Activity.create(:creator_id => @connection.user_id, :user_id => @connection.owned_by, :activityType => 10)
        #Activity.create(:creator_id => @connection.owned_by, :user_id => @connection.user_id, :activityType => 10)

        # Create a whiteboard activity log
        Whiteboard.createActivity(:user_connection, "{user.teacher.profile_link} just connected with {tag.teacher.profile_link} you should too!", User.find(@connection.user_id))

        # Redirect to My Connections page
        respond_to do |format|
          format.html { redirect_to :my_connections }
        end
      end
    end
  end

  def my_connections
    @connections= Connection.not_pending.find(:all, :conditions => ['owned_by = ?', self.current_user.id])
  end

  def pending_connections
    @connections= Connection.find(:all, :conditions => ['user_id = ? AND pending = true', self.current_user.id])
    @my_pending_connections=Connection.find(:all, :conditions => ['owned_by = ? AND pending = true', self.current_user.id])
  end

  def userconnections
    @user= User.find(params[:id])
    @connections = Connection.not_pending.find_for_user(params[:id])
    @my_connections = Connection.find_for_user(self.current_user.id)
  end

  def add_and_redir

    # Make sure we have a user_id
    unless params.has_key?("user_id")
      raise StandardError, "Were missing the user id to connect to"
    end

    # Make sure we have a redirection url
    unless params.has_key?("redir")
      raise StandardError, "We can't redirect you anywhere unless you provide us with the url"
    end

    # Create the connection and redirect
    self.add_connection(false)
    redirect_to params['redir']
  end

  def inviteconnections
    @my_connection = Connection.find_for_user(self.current_user.id)
    @default_message = "Hey! I'd love to add you to my professional teaching network at DemoLesson."
  end

  def inviteconnection
    if params[:emails].size == 0
      redirect_to :back, :notice => "Must have at least one email."
    end
    notice = []
    params[:emails].split(',').each do |email|
      # Clean up the email
      email = email.strip

      begin
        # Parse the email address
        mail = Mail::Address.new(email)
        demail = mail.address

        # Find the user by the provided email
        @user = User.find(:first, :conditions => ["email = ?", email])

        # If the user exists run a add connection
        if @user != nil

          # Make sure the user has a teacher profile
          if @user.teacher
            # This connection is now like a normal connection request
            Connection.add_connect(self.current_user.id, @user.id)

            # Notify the current session user
            notice << "Your connection request to " + demail + " has been sent."

          # If the user is not a teacher then do notify that a connection cannot be made
          else
            notice << email + " cannot be connected with."
          end

        # If the email is not tied to a member then invite them
        else

          # Create a new invitation record
          @invite = ConnectionInvite.new
          @invite.user_id = self.current_user.id
          @invite.email = demail

          # Try to save the invite
          if @invite.save

            # Create a random string for inviting
            invitestring = User.random_string(20)

            # Add the generated invitation string into the invitation
            @invite.update_attribute(:url, invitestring + @invite.id.to_s)

            # Generate the invitation url to be added to the email
            url = "http://#{request.host_with_port}/card?i=" + @invite.url

            # Send out the email
            mail = UserMailer.connection_invite(self.current_user.name, email, url, params[:message]).deliver

            # Notify the current session member that ht e email was sent
            notice << "Your invite to " + demail + " has been sent."

            # Log an analytic
            self.log_analytic(:connection_invite_sent, "User invited people to the site to connect.", @user)

          # If there were errors saving then let the current session member know
          else 
            notice << email + ": "+ @invite.errors.full_messages.to_sentence
          end
        end

      # If the email could not be parsed let the current session member know
      rescue Mail::Field::ParseError
        notice << "Could not parse " + email
      rescue
        notice << "Unknown Error"
      end
    end

    # Take us home
    redirect_to :root, :notice => notice.join(' ')
  end

  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
    @connection = Connection.find(params[:id])
    @connection.destroy

    respond_to do |format|
      format.html { redirect_to connections_url }
      format.json { head :ok }
    end
  end
end
