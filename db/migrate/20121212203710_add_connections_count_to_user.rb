class AddConnectionsCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :connections_count, :integer, :default => 0

	User.reset_column_information
	User.all.each do |user|
		User.update_counters user.id, :connections_count => user.connections.length
	end
  end
end
