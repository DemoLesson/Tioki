class VouchedSkill < ActiveRecord::Base
  belongs_to :vouch
  belongs_to :user
  belongs_to :skill
  belongs_to :voucher, :class_name => 'User'

  def skill_group
    skill.skill_group
  end
end
