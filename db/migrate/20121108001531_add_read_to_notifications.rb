class AddReadToNotifications < ActiveRecord::Migration
  def up
	add_column :notifications, :read, :bool
  end
  def down
  	remove_column :notifications, :read
  end
end
