class AddEmailedToNotifications < ActiveRecord::Migration
	def up
		add_column :notifications, :emailed, :boolean
	end

	def down
		remove_column :notifications, :emailed
	end
end
