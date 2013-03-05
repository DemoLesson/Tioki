class Authentication < ActiveRecord::Base
  attr_accessible :service, :unique_identifier, :user_id
end
