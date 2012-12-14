require 'uuidtools'

class LoginToken < ActiveRecord::Base
	belongs_to :user

	def self.generate_token_for!(user)
		#destroy old token, user_id must be unique
		token = LoginToken.find_by_user_id(user.id)
		if token
			token.destroy
		end
		token_value = UUIDTools::UUID.timestamp_create().to_s
		expires_at = Time.now + 1.week
		LoginToken.create!(:user_id => user.id, :expires_at => expires_at, :token_value => token_value)
	end
end
