class AddGroupIdToJobs < ActiveRecord::Migration
  def up
  	add_column :jobs, :group_id, :integer
  end

  def down
  	remove_column :jobs, :group_id
  end
end
