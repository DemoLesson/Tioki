class AddVideoIdToApplications < ActiveRecord::Migration
  def up
  	add_column :applications, :video_id, :integer
  	add_column :applications, :submitted, :integer, :default => 0
  end

  def down
  	remove_column :applications, :video_id
  	remove_column :applications, :submitted
  end
end
