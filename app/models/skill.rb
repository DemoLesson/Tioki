class Skill < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :skill_group_id

  has_many :skill_claims, :dependent => :destroy
  has_many :vouched_skills, :dependent => :destroy
  has_many :returned_skills, :dependent => :destroy

  # Video Skills
  has_and_belongs_to_many :videos, :join_table => 'videos_skills'

  belongs_to :skill_group

  has_many :technology_tags, :dependent => :destroy
  has_many :technology, :through => :technology_tags
end
