class AddGroups < ActiveRecord::Migration
  	def up
		create_table :groups do |t|
			t.string :name, :null => false
			t.text :description, :null => false, :default => ''
			t.integer :permissions, :null => false, :default => 0
			t.timestamps
		end

		create_table :users_groups do |t|
  			t.column :user_id, :integer
      		t.column :group_id, :integer
     		t.timestamps
    	end
	end

	def down
		drop_table :groups
		drop_table :users_groups
	end
end
