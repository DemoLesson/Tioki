desc "This task is called by the Heroku scheduler add-on"
task :email_jobs => :environment do
  if Time.now.friday?    
    Teacher.all.each do |teacher|
      #email set to elijahgreen@gmail.com for testing purposes
      if teacher.currently_seeking == true && teacher.user.email_permissions['email_subscription'] == true && teacher.user.email == "elijahgreen@gmail.com"
        UserMailer.weeklyemail(teacher).deliver
      end
    end
  end
end
