class Vouch < ActiveRecord::Base
  validates_presence_of :vouchee_id
  validates_presence_of :email

  has_many :vouched_skills, :dependent => :destroy
  has_many :skill_to_vouch

  #vouched skills that aren't requested to be vouched
  #but instead  were given out by the user doing the vouch request
  has_many :returned_skills, :dependent => :destroy

  belongs_to :vouchee, :class_name => 'User'
  belongs_to :voucher, :class_name => 'User'
end
