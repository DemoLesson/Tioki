class AddApplicationIdToInterview < ActiveRecord::Migration
  def up
  	add_column :interviews, :application_id, :integer
  	change_column :applications, :status, :string
  end

  def down
  	remove_column :interviews, :application_id
  end
end
