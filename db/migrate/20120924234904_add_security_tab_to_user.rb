class AddSecurityTabToUser < ActiveRecord::Migration
  def up
	add_column :users, :privacy, :integer, :default => 0, :null => false
  end

  def down
  	remove_column :users, :privacy
  end
end
