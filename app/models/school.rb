class School < ActiveRecord::Base
  acts_as_mappable
  acts_as_gmappable :msg => "You don't have a location set yet, or it is invalid."
  acts_as_gmappable :check_process => false
  
  belongs_to :user, :foreign_key => :owned_by
  attr_protected :owned_by

  has_many :jobs
  
  has_attached_file :picture,
                    :styles => { :medium => "201x201>", :thumb => "100x100", :tiny => "45x45" },
                    :storage => :s3,
                    :content_type => [ 'image/jpeg', 'image/png' ],
                    :s3_credentials => Rails.root.to_s+"/config/s3.yml",
                    :url  => '/schools/:style/:basename.:extension',
                    :path => 'schools/:style/:basename.:extension',
                    :bucket => 'DemoLessonS3',
                    :processors => [:thumbnail, :timestamper],
                    :date_format => "%Y%m%d%H%M%S"
                    
  validates_attachment_content_type :picture, :content_type => [/^image\/(?:jpeg|gif|png)$/, nil], :message => 'Uploading picture failed.'
  validates_attachment_size :picture, :less_than => 2.megabytes,
                                     :message => 'Picture was too large, try scaling it down.'

  def gmaps4rails_address
    "#{self.map_address}, #{self.map_city}, #{self.map_state}, #{self.map_zip}"
  end
  
  def jobs
    @jobs = Job.find(:all, :conditions => ['school_id = ? AND active = 1', self.id])
    return @jobs
  end
  
  def self.job_owner(job_id)
    @job = Job.find(job_id)
    @school = School.find(@job.school_id)
    return @school.owned_by
  end
  
  def belongs_to_me(current_user)
    if self.owned_by == current_user.id
      return true
    else
      return false
    end
  end
  
  def remove_associated_data
    @jobs = Job.find(:all, :conditions => ['school_id = ?', self.id])
    @jobs.each do |job|
      @applications = Application.find(:all, :conditions => ['job_id = ?', job.id])
      @applications.each do |application|
        @activities = Activity.find(:all, :conditions => ['application_id = ?', application.id])
        @activities.map(&:destroy)
      end
      @applications.map(&:destroy)
      
      @interviews = Interview.find(:all, :conditions => ['job_id = ?', job.id])
      @interviews.each do |interview|
        @activites = Activity.find(:all, :conditions => ['interview_id = ?', interview.id])
      end
      @interviews.map(&:destroy)
    end
    
    @jobs.map(&:destroy)
  end
  
end
