class Group < ActiveRecord::Base
  has_and_belongs_to_many :user, :join_table => 'users_groups'

  def permissions
    super.to_switch(APP_CONFIG['bitswitches']['group_permissions'])
  end
end
