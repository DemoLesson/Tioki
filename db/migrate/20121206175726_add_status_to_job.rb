class AddStatusToJob < ActiveRecord::Migration
  def up
  	add_column :jobs, :status, :string
  end
  def down
  	remove_column :jobs, :status
  end
end
