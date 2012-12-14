class JobPack < ActiveRecord::Base
	attr_accessible :group, :jobs, :expiration, :inception, :charge_token, :card_token, :refunded, :amount, :additiona_data

	belongs_to :group
end