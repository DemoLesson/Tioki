class SkillGroup < ActiveRecord::Base
  validates_presence_of :badge_url
  validates_presence_of :name

  has_many :skills, :dependent => :destroy
  has_many :skill_group_descriptions, :dependent => :destroy

  def badge_name
    name.delete("&").split(' ').map(&:downcase).join('-')
  end
  
end
