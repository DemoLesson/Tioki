class Organization < ActiveRecord::Base
  belongs_to :user, :foreign_key => :owned_by
  attr_protected :owned_by

  validates_uniqueness_of :owned_by

  default_scope joins(:user).where('users.deleted_at' => nil).readonly(false)

  def schools
    return self.user.schools
  end

  def jobcount
    jobs=0
    self.user.schools.each do |school|
      jobs+=school.jobs.count
    end
    return jobs
  end

  def admincount
    shared = SharedUsers.find(:all, :conditions => ['owned_by = ?', :owned_by]).count
    return shared+1
  end

  def applicationcount
    applications=0
    self.user.schools.each do |school|
      school.jobs.each do |job|
        applications+=job.applications.count
      end
    end
    return applications
  end

  #if no organization name is present, use the name of the first school
  def oname
    if self.name == nil || self.name == ""
      if self.user.school.name == nil 
        return ""
      else 
        return self.user.school.name
      end
    else
      return self.name
    end
  end
end
