class RenamePrivacyOnUser < ActiveRecord::Migration
  def up
		rename_column :users, :privacy, :privacy_public
		add_column :users, :privacy_connected, :integer
		add_column :users, :privacy_recruiter, :integer
  end

  def down
	  rename_column :users, :privacy_public, :privacy
	  remove_column :users, :privacy_connected
	  remove_column :users, :privacy_recruiter
  end
end
