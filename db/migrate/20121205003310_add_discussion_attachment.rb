class AddDiscussionAttachment < ActiveRecord::Migration
  def up
  	add_column :discussions, :owner, :string
  	add_index :discussions, :owner
  end

  def down
  	remove_column :discussions, :owner
  end
end
