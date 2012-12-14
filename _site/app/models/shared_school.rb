class SharedSchool < ActiveRecord::Base
  belongs_to :user
  #Make sure a shared school can only be in the table once
  validates_uniqueness_of :school_id, :scope => :user_id
end
