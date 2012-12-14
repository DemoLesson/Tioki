class Job < ActiveRecord::Base
  belongs_to :school
  belongs_to :group
  
  has_and_belongs_to_many :credentials
  has_and_belongs_to_many :subjects
  
  has_many :applications
  has_many :winks
  has_many :interviews, :dependent => :destroy
  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets, :reject_if => lambda {|a| a[:name].blank? }, :allow_destroy => true
  reverse_geocoded_by :latitude, :longitude
  
  scope :is_active, where(:active => 'Running')
  
  #scope :dry_clean_only, joins(:washing_instructions).where('washing_instructions.dry_clean_only = ?', true)
  
  scoped_search :on => [:title, :description]

  #Don't show if user account is deactivated

  #default_scope joins(:school => :user).where('users.deleted_at' => nil).readonly(false)
  
  self.per_page = 15
  
  #searchable do 
  #  text :description, :title
  #end
  
  def self.search(search)
    if search
      find(:all, :conditions => ['jobs.title LIKE ? OR jobs.description LIKE ?', "%#{search}%", "%#{search}%"])
    else
      find(:all)
    end
  end
  
  def school
    @school = School.find(self.school_id)
    return @school
  end
  
  def subjects
    @subjects = JobsSubjects.find(:all, :conditions => ['job_id = ?', self.id])
    return @subjects
  end
  
  def update_subjects(subjects)
    JobsSubjects.delete_all(["job_id = ?", self.id])
    
    subjects.each do |subject|
      @jobs_subjects = JobsSubjects.new
      @jobs_subjects.job_id = self.id
      @jobs_subjects.subject_id = subject.to_i
      @jobs_subjects.save
    end
  end
  
  def zipcode
    return self.school.map_zip
  end
  
  def apply(user_id)
    @application = Application.find(:first, :conditions => ['job_id = ? AND user_id = ?', self.id, user_id])
    if @application == nil
      @application = Application.create!(:job_id => self.id, :user_id => user_id, :status => 1, :viewed => 0)
      UserMailer.teacher_applied(self.school_id, self.id, user_id).deliver
      @application.activify
    else
      @application.deactivify
      @application.destroy
    end
  end
  
  def applicants
    @applicants = Application.find(:all, :conditions => ['job_id = ?', self.id])
    return @applicants
  end
  
  def new_applicants
    @applicants = Application.find(:all, :conditions => ['job_id = ? AND (status = ? || status =?)', self.id, 'Not Reviewed', nil])
  end
  
  def belongs_to_me(user)
    if !group_id.nil?
      return group.user_permissions['administrator']
    end

    @school = School.find(self.school)
    belongs = false
    if @school != nil
      if user.id == @school.owned_by
        belongs = true
      end
    end
    return belongs
  end

  #for full admins compare the owned_by of the user to the owned_by of the school
  #for limited admins look up it's row in SharedSchools
  def shared_to_me(user)
    if !group_id.nil?
      return group.user_permissions['administrator']
    end
    
    @school= School.find(self.school)
    @shared= SharedUsers.find(:first, :conditions => { :user_id => user.id})
    if @school != nil && @shared != nil
      if user.is_limited == false
        if @shared.owned_by == @school.owned_by
          return true
        else
          return false
        end
      else
        if SharedSchool.find(:first, :conditions => { :user_id => user.id, :school_id => @school.id}).nil?
          return false
        else
          return true
        end
      end
    else
      return false
    end
  end

  def new_asset_attributes=(asset_attributes) 
    assets.build(asset_attributes)
    #asset_attributes.each do |attributes| 
    #  assets.build(attributes)
    #end 
  end

  def start_date_string
    #can't call to_s with an argument on a nil object
    begin
      start_date.to_s(:jobpicker_time)
    rescue
      start_date
    end
  end

  def deadline_string
    #can't call to_s with an argument on a nil object
    begin
      deadline.to_s(:jobpicker_time)
    rescue
      deadline
    end
  end

  def start_date_string=(start_date_str)
    self.start_date = Time.strptime(start_date_str, "%m/%d/%Y").end_of_day
  rescue ArgumentError
    @state_date_invalid = true
  end

  def deadline_string=(deadline_str)
    self.deadline = Time.strptime(deadline_str, "%m/%d/%Y").end_of_day
  rescue ArgumentError
    @deadline_invalid = true
  end

  def validate
    errors.add(:start_date, "is invalid") if @start_date_invalid
    errors.add(:deadline, "is invalid") if @deadline_invalid
  end
  
  def cleanup
    @applications = Application.find(:all, :conditions => ['job_id = ?', self.id])
    @applications.each do |application|
      @activity = Activity.find(:all, :conditions => ['application_id = ?', application.id])
      @activity.map(&:destroy)
    end
    @applications.map(&:destroy)
  end

  def save_assets 
    assets.each do |asset| 
      asset.save
    end
  end
  
end
