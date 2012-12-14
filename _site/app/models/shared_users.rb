class SharedUsers < ActiveRecord::Base
  alias_attribute :owner_id, :owned_by
  
  belongs_to :owner, :foreign_key => :owned_by, :class_name => 'User'
  belongs_to :user, :class_name => 'User'
end
