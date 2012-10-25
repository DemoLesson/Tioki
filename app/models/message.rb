class Message < ActiveRecord::Base
  attr_accessible :user_id_to, :user_id_from, :read, :subject, :body
  validates_presence_of :subject, :body, :message => "Please enter a subject and/or message."

  self.per_page = 15

  def activify
    @activity = Activity.create!(:user_id => self.user_id_to, :creator_id => self.user_id_from, :activityType => 1, :message_id => self.id, :interview_id => 0, :application_id => 0)
  end

  def deactivify
    @activity = Activity.find(:first, :conditions => ['message_id = ?', self.id])
    if @activity
      @activity.destroy
    end
  end

  def sender
    @user = User.unscoped.find(self.user_id_from) rescue nil
    return @user
  end

  def receiver
    @user = User.unscoped.find(self.user_id_to) rescue nil
    return @user
  end

  def mark_read
    self.read = true
    self.save
  end

  def self.send(opts = {})

    # Return false if a subject and body were not provided
    return false if opts[:subject].nil? || opts[:body].nil? || opts[:to].nil?

    # Make sure user is a user model
    to = User.find(opts[:to]) unless opts[:to].is_a?(User)

    # Get from value from user.current unless one was specified
    from = User.current if opts[:from].nil?

    # Get from value from the opts array
    unless opts[:from].nil?
      from = User.find(opts[:from]) unless opts[:from].is_a?(User)
      from = opts[:from] if opts[:from].is_a?(User)
    end

    # Get subject and body
    subject = opts[:subject]
    body = opts[:body]

    # Allow setting if the message was read by default
    read = opts[:read] unless opts[:read].nil?
    read = false if opts[:read].nil?

    # Create the message
    msg = new
    dump msg
    msg.user_id_to = to.id.to_s
    msg.user_id_from = from.id
    msg.subject = subject
    msg.body = body
    msg.read = read

    if msg.save
      # Notify the user of the message via email
      UserMailer.message_notification(msg.user_id_to, msg.subject, msg.body, msg.id, from.name).deliver
      return true
    else
      return false
    end
    
  end
 
end
