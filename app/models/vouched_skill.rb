class VouchedSkill < ActiveRecord::Base
  belongs_to :vouch
  belongs_to :user
  belongs_to :skill
  belongs_to :voucher, :class_name => 'User'
	#validates_uniqueness_of :voucher_id, :scope => [:skill_id, :user_id], :allow_nil => true

  def skill_group
    skill.skill_group
  end
end
