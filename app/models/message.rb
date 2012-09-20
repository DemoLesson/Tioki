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
    @user = User.find(self.user_id_from)
    return @user
  end

  def receiver
    @user = User.find(self.user_id_to)
    return @user
  end

  def mark_read
    self.read = true
    self.save
  end
 
end
