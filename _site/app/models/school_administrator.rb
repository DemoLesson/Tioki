class SchoolAdministrator < ActiveRecord::Base
  belongs_to :user
  belongs_to :school

  validates_presence_of :user
  validates_presence_of :school
  validate :admin_user

  def admin_user
    errors.add(:user, "is not an administrator") unless user and user.is_admin?
  end
end
