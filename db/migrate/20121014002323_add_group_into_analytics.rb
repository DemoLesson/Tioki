class AddGroupIntoAnalytics < ActiveRecord::Migration
  def up
  	add_column :analytics, :group, :string
  end

  def down
  	remove_column :analytics, :group
  end
end
