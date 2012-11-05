class AddEmailPermissionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_permissions, :integer, :default => 0
  end
end
