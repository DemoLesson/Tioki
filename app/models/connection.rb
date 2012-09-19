class Connection < ActiveRecord::Base
  belongs_to :user
  scope :not_pending, where(:pending => false)

  # Get information on my connections
  def self.mine(args = {})
    # Set the user to lookup
    a = User.current.id if args[:user].nil?
    a = args[:user] unless args[:user].nil?

    # Get only the connections I instigated
    tmp = self.where('`owned_by` = ?', a) unless args[:creator].nil? || !args[:creator]

    # Get all connections involving me
    tmp = self.where('`owned_by` = ? || `user_id` = ?', a, a) if args[:creator].nil? || !args[:creator]

    # Set pending true or false
    tmp = tmp.where('`pending` = ?', args[:pending]) unless args[:pending].nil?

    # Return the modified object
    return tmp
  end

  # Get information on another user
  def self.user(user_id)
    self.mine(:user => user_id, :pending => false)
  end

  def self.find_for_user(user_id)
    Connection.find(:all, :conditions => ['owned_by = ?', user_id])
  end

  def owner
    return User.find(self.owned_by)
  end

  def self.add_connect(current_user_id, user_id)
    @previous = Connection.find(:first, :conditions => ['owned_by = ? AND user_id = ?', current_user_id, user_id])

    if @previous == nil

      # Create the connection
      @connection = Connection.new
      @connection.owned_by = current_user_id
      @connection.user_id = user_id

      # If everything saved ok
      if @connection.save
        
        # Notify the other user of my connection request
        UserMailer.userconnect(current_user_id, user_id).deliver
        return true
      else
        return false
      end
    else
      return false
    end
  end
end
