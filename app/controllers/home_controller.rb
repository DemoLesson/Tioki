class HomeController < ApplicationController
  layout 'standard'
  
  USER_ID, PASSWORD = "upstartla", "incubator"
  USER_ID_M, PASSWORD_M = "muckerlab", "incubator"
  before_filter :authenticate, :only => [ :video1, :video2, :video3, :video4 ]
  before_filter :muckerlab_auth, :only => [ :muckerlab ]
    
  def index
    if not self.current_user.nil?
      if self.current_user.is_admin?
        @schools = self.current_user.all_schools
        
        @jobs = self.current_user.all_jobs_for_schools

        @activities = self.current_user.activities

        @pins = self.current_user.pins.count

        @administrators = self.current_user.organization.admincount

        @interviews = @jobs.inject(0) do |total, job|
          total += job.interviews.count
        end
        
        if self.current_user.is_shared && !self.current_user.is_limited
          #if shared and not limited user get the activities for the master admin
          admin = SharedUsers.find(:first, :conditions => { :user_id => self.current_user.id})
          @activities = @activities + Activity.find(:all, :conditions => ['user_id = ? OR user_id = 0', admin.owned_by], :order => 'created_at DESC')
        end

        @applicants = @jobs.inject(0) do |total, job|
          total += job.new_applicants.count
        end         
      elsif not self.current_user.teacher.nil?
        boardPage = params[:boardPage].nil? ? 0 : params[:boardPage].to_i - 1
        @whiteboard = Whiteboard.getActivity.offset((boardPage * 5 / boardPage rescue 0)).limit(5)

        @pendingcount = self.current_user.pending_connections.count

        @user = User.find(self.current_user)

        @jobs = Job.find(:all, :conditions => ['active = ?', true], :limit => 4, :order => 'created_at DESC')
        
        @featuredjobs = Job.find(:all, :conditions => ['active = ?', true], :order => 'created_at DESC')

        @interviews = self.current_user.teacher.interviews

        #Activites currently only deal with connections
        #Trying to only have a single query due to recent problems so using find_by_sql
        #Should change as soon as possible as this is database engine specific (currently MySQL)
        @activities = Activity.find_by_sql(['SELECT a.* FROM activities a, connections c WHERE c.owned_by = ? and a.creator_id = c.user_id and a.activityType = 10', self.current_user.id], :order => 'created_at DESC',:limit => 4)
      end
    end

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
    unless self.current_user.nil?
      name = self.current_user.name
    else
      name = "[name]"
    end

    @default_message = "I'd love to add you to my professional teaching network at DemoLesson. We can
connect and the profile is super easy to make. Check it out!\n\n-#{name}"
  end

  def school_splash
  end
  
  def school_signup
  end
  
  def customers
  end  
  
  def press
  end  

  def school_thankyou
  end
  
  def dmca
  end  
  
  def school_signup_email
     @signup = params[:signup]
     @name = @signup[:name]
     @schoolname = @signup[:schoolname]
     @email = @signup[:email]
     @phonenumber = @signup[:phonenumber]

     UserMailer.school_signup_email(@name, @schoolname, @email, @phonenumber).deliver

      respond_to do |format|
         format.html { redirect_to :school_thankyou}

      end
  end
  
  def site_referral_email

    if params[:referral][:teachername].nil? || params[:referral][:teachername].empty?
      flash[:notice] = "Name is required"
      return redirect_to '/site_referral'
    end

    if params[:referral][:emails].nil? || params[:referral][:emails].empty?
      flash[:notice] = "Email is required"
      return redirect_to '/site_referral'
    end

    # Get the post data key
    @referral = params[:referral]

    # Interpret the post data from the form
    @teachername = @referral[:teachername]
    @emails = @referral[:emails]
    @message = @referral[:message]

    # Swap out any instances of [name] with the name of the sender
    @message = @message.gsub("[name]", @teachername);

    # Swap out all new lines with line breaks
    @message = @message.gsub("\n", '<br />');

    # Get the current user if applicable
    user = self.current_user unless self.current_user.nil?

    # Send out the email to the list of emails
    UserMailer.refer_site_email(@teachername, @emails, @message, user).deliver

    # Return user back to the home page 
    respond_to do |format|
      format.html { redirect_to "http://www.demolesson.com", :notice => 'Email Sent Successfully' }
    end
  end

  def whiteboard_share
    redirect_to :root if self.current_user.nil?
    Whiteboard.createActivity(:share, "{user.teacher.profile_link} Shared: " + params[:message], '', {"deleteable" => true}) unless params[:message].nil?
    redirect_to :root
  end

  def whiteboard_rmv
    w = Whiteboard.find(params[:post])
    redirect_to :root if self.current_user.nil? || (w.user != self.current_user && !self.current_user.is_admin)
    w.destroy; redirect_to :root
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
