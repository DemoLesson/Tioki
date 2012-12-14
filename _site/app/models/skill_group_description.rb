class SkillGroupDescription < ActiveRecord::Base
  validates_presence_of :description
  validates_presence_of :user_id
  validates_presence_of :skill_group_id

  belongs_to :user
  belongs_to :skill_group
end
