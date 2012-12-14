class SkillToVouch < ActiveRecord::Base
  belongs_to :vouch
  belongs_to :skill
end
