class Interview < ActiveRecord::Base
  attr_accessible :interview_type, :location, :school_location, :message, :teacher_id, :job_id, :date, :date_alternate, :date_alternate_second, :selected
  
  belongs_to :job
  belongs_to :teacher # Migration
  belongs_to :user
  
  def responded
    
  end

  def application
    return Application.find(:first, :conditions => ['teacher_id = ? AND job_id = ?', self.teacher_id, self.job_id])
  end
  
  def activify
    @activity = Activity.create!(:user_id => School.job_owner(job_id), :creator_id => Teacher.owner_id(self.teacher_id), :activityType => 2, :message_id => 0, :interview_id => self.id, :application_id => Application.find_by_teacher_job(self.teacher_id, self.job_id).id)    
  end
  
  def deactivify
    @activity = Activity.find(:first, :conditions => ['interview_id = ?', self.id])
    @activity.destroy
  end
end
