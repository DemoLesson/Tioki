class AddPermissionsToUsersGroup < ActiveRecord::Migration
  def up
    add_column :users_groups, :permissions, :integer, :default => 0
  end

  def down
    remove_column :users_groups, :permissions
  end
end
