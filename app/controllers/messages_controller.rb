class MessagesController < ApplicationController
  before_filter :login_required
  
  # GET /messages
  # GET /messages.xml
  def index
    @messages = Message.paginate(
			:page => params[:page], 
			:conditions => ['user_id_to = ? && replied_to_id is null', self.current_user.id],
			:order => 'updated_at DESC' )
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end
  
  def sent
    @messages = Message.paginate(
			:page => params[:page],
			:conditions => ['user_id_from = ?', self.current_user.id], 
			:order => 'created_at DESC' )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end   
  end

  # GET /messages/1
  # GET /messages/1.xml
  def show
    @message = Message.find(params[:id])

		#Only mark read if the receiver was the one who viewed it
		if self.current_user.id == @message.user_id_to
			@message.mark_read
		end
    
    respond_to do |format|
			if self.current_user.id == @message.user_id_to || self.current_user.id == @message.user_id_from
				format.html # show.html.erb
				format.xml  { render :xml => @message }
			else
        format.html { redirect_to :root, :notice => 'Unauthorized' }
			end
    end
  end

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new
		if params[:replied_to_id]
			@replied_to_message = Message.find(params[:replied_to_id])

			#Check if this person is allowed to replied
			#to reply and see these messages
			if @replied_to_message.receiver.id != self.current_user.id
				@replied_to_message = nil
			end
		end
		@user = User.find(params[:user_id_to])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # POST /messages
  # POST /messages.xml
  def create
    @message = Message.new(params[:message])

		@message.read = false
		@message.user_id_from = self.current_user.id
    
    respond_to do |format|
			if @message.save
				UserMailer.message_notification(
					@message.user_id_to, 
					@message.subject, 
					@message.body, 
					@message.id, 
					self.current_user.name).deliver

					#Log in Analytics
					self.log_analytic(:message_sent, "User to user message.", @message, [], :messages)

					format.html { redirect_to(:messages, 
						:notice => 'Your message to '+User.find(@message.user_id_to).name+' was sent.') }
					format.xml { render :xml => @message, :status => :created, :location => @message }
			else
					format.html { redirect_to(:back, :notice => @message.errors.full_messages.to_sentence) }
			end
		end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to(messages_url) }
      format.xml  { head :ok }
    end
  end
end
