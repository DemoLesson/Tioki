class ConnectionInvite < ActiveRecord::Base
  attr_protected :created_id, :pending
  belongs_to :user
  belongs_to :created_user, :class_name => 'User'
end
