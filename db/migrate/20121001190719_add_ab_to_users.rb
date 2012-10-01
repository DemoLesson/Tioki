class AddAbToUsers < ActiveRecord::Migration
  def up
    add_column :users, :ab, :string
  end

  def down
    remove_column :users, :ab
  end
end
