class HomeController < ApplicationController
  layout 'standard'
  
  USER_ID, PASSWORD = "upstartla", "incubator"
  USER_ID_M, PASSWORD_M = "muckerlab", "incubator"
  before_filter :authenticate, :only => [ :video1, :video2, :video3, :video4 ]
  before_filter :muckerlab_auth, :only => [ :muckerlab ]
    
  def index
    if self.current_user.nil?
      
    elsif self.current_user.school != nil || self.current_user.is_shared == true
      puts "admin user"
      
      @jobs = []
      if self.current_user.is_limited == true
        @schools = self.current_user.sharedschools
      else
        @schools = self.current_user.schools
      end
      @schools.each do |school|
        @jobs_sign = Job.find(:all, :conditions => ['school_id = ? AND active = ?', school.id, true], :order => 'created_at DESC')
        @jobs = @jobs+@jobs_sign
      end
      
      @activities = Activity.find(:all, :conditions => ['user_id = ? OR user_id = 0', self.current_user.id], :order => 'created_at DESC')

      if self.current_user.is_shared && !self.current_user.is_limited
        #if shared and not limited user get the activities for the master admin 
        admin = SharedUsers.find(:first, :conditions => { :user_id => self.current_user.id})
        @activities = @activities + Activity.find(:all, :conditions => ['user_id = ? OR user_id = 0', admin.owned_by], :order => 'created_at DESC')
      end
      
      @applicants = 0
      @jobs.each do |job|
        @applicants = @applicants+job.new_applicants.count
      end
      
    elsif self.current_user.teacher != nil
      @user = User.find(self.current_user.id)
      @jobs = Job.find(:all, :conditions => ['active = ?', true], :limit => 4, :order => 'created_at DESC')
      @featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')
      @interviews = Interview.find(:all, :conditions => ['teacher_id = ?', self.current_user.teacher.id])
    end
    
    @alpha = Alpha.new
    
    respond_to do |format|
      format.html # beta.html.erb
    end
  end
  
  def about
  end
  
  def privacy
  end
  
  def terms_of_service
  end
  
  def contact
  end
  
  def how_it_works_teachers
  end
  
  def how_it_works_schools
  end
  
  def video1
  end
  
  def video2
  end
  
  def video3
  end
  
  def video4
  end
  
  def muckerlab
  end
  
  def teachers_faq
   end

  def schools_faq
  end
  
  def site_referral
  end

  def school_splash
  end
  
  def school_signup
  end
  
  def customers
  end  
  
  def school_signup_email
     @signup = params[:signup]
     @name = @signup[:name]
     @schoolname = @signup[:schoolname]
     @email = @signup[:email]
     @phonenumber = @signup[:phonenumber]

     UserMailer.school_signup_email(@name, @schoolname, @email, @phonenumber).deliver

      respond_to do |format|
         format.html { redirect_to "http://www.demolesson.com", :notice => 'Thank you for signing up! We will be in contact with you shortly.' }

      end
  end
  
   def site_referral_email
       @referral = params[:referral]
       @teachername = @referral[:teachername]
       @name = @referral[:name]
       @email = @referral[:email]

       UserMailer.refer_site_email(@teachername, @name, @email).deliver

        respond_to do |format|
           format.html { redirect_to "http://www.demolesson.com", :notice => 'Email Sent Successfully' }

        end
   end
  
  private
   def authenticate
        authenticate_or_request_with_http_basic do |id, password| 
        id == USER_ID && password == PASSWORD
      end
   end
  
   def muckerlab_auth
        authenticate_or_request_with_http_basic do |id, password| 
        id == USER_ID_M && password == PASSWORD_M
   end
  end
end
