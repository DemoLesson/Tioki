class UserMailer < ActionMailer::Base
  default :from => "demolesson@demolesson.com"
  
  def message_notification(user_id, subject, body, id, name)
      
      @user = User.find(user_id)
      
      message_body = "Hi "+@user.name+",\n\n"+name+" sent you a new message on DemoLesson:\n\n"+body+"\n\nTo reply, click the link below:\n http://demolesson.com/messages/"+id.to_s+"\n\n-------------------\nYou received this message because you are a member of DemoLesson.com"
      
      mail(:to => @user.email,
           :subject => name+' messaged you: '+subject, :body => message_body)
  end
  
  def interview_notification(user_id)
    
  end
  
  def date_select_notification
  
  end
  
end
