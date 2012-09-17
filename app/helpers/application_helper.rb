module ApplicationHelper  
  def current_user
    User.find(session[:user]) unless session[:user].nil?
  end
  
  def unread_messages
    @messages = Message.find(:all, :conditions => {:read => false, :user_id_to => self.current_user.id})
    return @messages.size
  end

  def pendingcount
    self.current_user.pending_count
  end
end
