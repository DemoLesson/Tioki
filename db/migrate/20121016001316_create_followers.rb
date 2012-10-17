class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :user_id
      t.integer :discussion_id

      t.timestamps
    end

		add_index :followers, :user_id
		add_index :followers, :discussion_id
  end
end
