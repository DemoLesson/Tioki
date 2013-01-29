class AddLinkTextToNotifications < ActiveRecord::Migration
	def up
		add_column :notifications, :link_text, :string
	end

	def down
		remove_column :notifications, :link_text
	end
end
