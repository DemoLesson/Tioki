class Application < ActiveRecord::Base
  has_many :assets, :dependent => :destroy
  belongs_to :job

  has_one :video
  has_one :interview

  scope :is_active, where(:status => 1)
	scope :is_submitted, where(:submitted => 1)

  def self.mine(args = {})

    # Set the user to lookup
    a = User.current.id if args[:user].nil?
    a = args[:user] unless args[:user].nil?

    # Get all my applications
    tmp = self.where('`user_id` = ?', a)

    # Filter down
    tmp = tmp.where('`viewed` = ?', args[:viewed]) unless args[:viewed].nil?
    tmp = tmp.where('`status` = ?', args[:status]) unless args[:status].nil?
    tmp = tmp.where('`status` != ?', args[:status!]) unless args[:status!].nil?

    return tmp
  end

  def self.find_by_user_job(user_id, job_id)
    Application.find(:first, :conditions => ['user_id = ? AND job_id = ?', self.user_id, self.job_id])
  end

  def user
    @user = User.find(self.user_id)
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
    @interviews = Interview.find(:first, :conditions => ['user_id = ? AND job_id = ?', self.user_id, self.job_id])
    
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

end
