class ReturnedSkill < ActiveRecord::Base
  belongs_to :vouch
  belongs_to :skill
end
