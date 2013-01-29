class AddFakeFilterToUsers < ActiveRecord::Migration
	def up
		add_column :users, :fake, :boolean, :default => false
	end

	def down
		remove_column :users, :fake
	end
end
