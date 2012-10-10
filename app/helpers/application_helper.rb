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

  def possesify(name)
    return name + "'" if name[-1] == 's'
    name + "'s"
  end

  def ablang(slug, uc = true)
    unless self.current_user.nil?
      ab = self.current_user.ab
      ab = ab.to_i if ab.is_a?(String) && ab.numeric?
    else
      ab = 'default'
    end

    AB::getLang(slug, ab, uc)
  end

  def e64(var)
    Base64.encode64 var
  end

  def d64(var)
    Base64.decode64 var
  end
end
