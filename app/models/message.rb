class Message < ActiveRecord::Base
  attr_accessible :user_id_to, :user_id_from, :read, :subject, :body, :tag
  validates_presence_of :subject, :body, :message => "Please enter a subject and/or message."

  self.per_page = 15

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

  def tag
    _map!(read_attribute(:tag))
  end

  def self.send!(to, opts = {})

    # Return false if a subject and body were not provided
    return false if opts[:subject].nil? || opts[:body].nil?

    # Make sure user is a user model
    to = User.find(to) unless to.is_a?(User)

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

    # Tag the message with an object
    tag = opts[:tag] unless opts[:tag].nil?

    # Create the message
    msg = new
    msg.user_id_to = to.id
    msg.user_id_from = from.id
    msg.subject = subject
    msg.body = body
    msg.read = read
    msg.tag = tag

    if msg.save
      
      # Notify the user of the message via email
      UserMailer.message_notification(
				msg.user_id_to, 
				msg.subject, 
				msg.body, 
				msg.id, 
				from.name, 
				msg.tag).deliver
      
      # Return true on success
      return true
    else

      # Return false on failure
      return false
    end
    
  end
 
end
