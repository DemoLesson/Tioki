class AddUserIdToSession < ActiveRecord::Migration
  def up
  	add_column :sessions, :user_id, :integer
  end

  def down
  	remove_column :sessions, :user_id
  end
end
