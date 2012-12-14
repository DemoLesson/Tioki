class Activity < ActiveRecord::Base
  attr_accessible :user_id, :creator_id, :activityType, :message_id, :interview_id, :application_id
  belongs_to :application
  belongs_to :user
  
  def creator
    begin
      @user = User.find(self.creator_id)
      return @user
    rescue
      @user = User.first
      return @user
    end
  end
  
  def teacher
    @teacher = Teacher.find_by_user_id(self.creator_id)
    return @teacher
  end
  
  def application_job
    begin
      @application = Application.find(self.application_id)
      @job = Job.find(@application.job_id)
      return @job
    rescue
      @job = Job.new
      @job.title = "Not found"
      return @job
    end
  end
  
  def application_school
    begin
      @application = Application.find(self.application_id)
      @job = Job.find(@application.job_id)
      @school = School.find(@job.school_id)
      return @school
    rescue
      @school = School.new
      @school.name = "Not found"
      return @school
    end
  end
  
  def interview
    begin
      @interview = Interview.find(self.interview_id)
      return @interview
    rescue
      @interview = Interview.new
      @interview.date = Time.at(0)
      return @interview
    end
  end
  
  def message
    begin
      @message = Message.find(self.message_id)
      return @message
    rescue
      @message = Message.new
      @message.subject = "Deleted message"
      return @message
    end
  end
  
end
