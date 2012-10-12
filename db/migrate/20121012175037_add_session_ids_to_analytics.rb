class AddSessionIdsToAnalytics < ActiveRecord::Migration
  def up
  	add_column :analytics, :session_id, :string
  end
  def down
  	remove_column :analytics, :session_id
  end
end
