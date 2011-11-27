class Application < ActiveRecord::Base
  
  def belongs_to_me
  
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
  
  def activify
    @activity = Activity.new
    @activity.user_id = School.find(Job.find(job_id).school_id).owned_by
    @activity.creator_id = Teacher.find(self.teacher_id).user_id
    @activity.activityType = 3
    @activity.message_id = 0
    @activity.interview_id = 0
    @activity.application_id = self.id
    @activity.save
  end
    
end
