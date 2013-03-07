class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :token, :secret
	belongs_to :user
end
