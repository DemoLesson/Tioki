class AddEmailedToNotifications < ActiveRecord::Migration
	def up
		add_column :notifications, :emailed, :boolean, :default => false
		add_column :notifications, :emailed_at, :datetime
		add_column :notifications, :bucket, :string
		add_column :users, :notification_intervals, :text
	end

	def down
		remove_column :notifications, :emailed
		remove_column :notifications, :emailed_at
		remove_column :notifications, :bucket
		remove_column :users, :notification_intervals
	end
end
