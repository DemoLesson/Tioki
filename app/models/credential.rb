class Credential < ActiveRecord::Base
  attr_accessible :credentialType, :name, :issuer, :state
  
  belongs_to :teacher # Migration
  belongs_to :user
  belongs_to :job
end
