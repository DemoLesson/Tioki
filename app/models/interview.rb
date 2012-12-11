class Interview < ActiveRecord::Base
  attr_accessible :interview_type, :location, :school_location, :message, :user_id, :job_id, :date, :date_alternate, :date_alternate_second, :selected
  
  belongs_to :job
  belongs_to :user
  belongs_to :teacher
  belongs_to :application

  def intDate
    case selected
    when 1
      return date.to_s(:datetime)
    when 2
      return date_alternate.to_s(:datetime)
    when 3
      return date_alternate_second.to_s(:datetime)
    else
      return 'Unscheduled'
    end
  end
end
