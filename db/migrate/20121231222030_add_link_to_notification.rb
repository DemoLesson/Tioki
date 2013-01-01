class AddLinkToNotification < ActiveRecord::Migration
	def up
		add_column :notifications, :link, :string
		add_column :notifications, :data, :text
		add_column :notifications, :triggered_id, :integer
	end

	def down
		remove_column :notifications, :link
		remove_column :notifications, :data
		remove_column :notifications, :triggered_id
	end
end