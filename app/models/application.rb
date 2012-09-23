class Application < ActiveRecord::Base
  has_many :assets, :dependent => :destroy
  belongs_to :job

  scope :is_active, where(:status => 1)

  def self.mine(args = {})

    # Set the user to lookup
    a = User.current.teacher.id if args[:teacher].nil?
    a = args[:teacher] unless args[:teacher].nil?

    # Get all my applications
    tmp = self.where('`teacher_id` = ?', a)

    # Filter down
    tmp = tmp.where('`viewed` = ?', args[:viewed]) unless args[:viewed].nil?
    tmp = tmp.where('`status` = ?', args[:status]) unless args[:status].nil?

    return tmp
  end
  
  def belongs_to_me
  
  end

  def self.find_by_teacher_job(teacher_id, job_id)
    @application = Application.find(:first, :conditions => ['teacher_id = ? AND job_id = ?', teacher_id, job_id])
    return @application
  end

  def teacher
    @teacher = Teacher.find(self.teacher_id)
    return @teacher
  end
  
  def reject
    self.status = 0
    self.save
  end

  def interview
    @interview = Interview.find_by_job_id(self.job_id)
    
    return @interview
  end
    
  def booked
    @interviews = Interview.find(:first, :conditions => ['teacher_id = ? AND job_id = ?', self.teacher_id, self.job_id])
    
    return @interviews
  end

  def belongs_to_me(user)
    job=Job.find_by_id(self.job_id)
    if job != nil 
      if job.belongs_to_me(user) || job.shared_to_me(user)
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def activify
    @activity = Activity.create!(:user_id => School.find(Job.find(job_id).school_id).owned_by, :creator_id => Teacher.find(self.teacher_id).user_id, :activityType => 3, :message_id => 0, :interview_id => 0, :application_id => self.id)
  end
    
  def deactivify
    @activity = Activity.find(:first, :conditions => ['application_id = ?', self.id])
    @interviews = Interview.find(:all, :conditions => ['job_id = ?', self.job_id])
    @interviews.map(&:destroy)
    if @activity != nil
      @activity.destroy
    end
  end

end
