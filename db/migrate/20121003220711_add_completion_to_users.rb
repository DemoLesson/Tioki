class AddCompletionToUsers < ActiveRecord::Migration
  def up
  	add_column :users, :completion, :integer
  end

  def down
  	remove_column :users, :completion
  end
end
