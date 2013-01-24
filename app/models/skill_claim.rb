class SkillClaim < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :skill_id

  belongs_to :user
  belongs_to :skill
  belongs_to :skill_group
end
