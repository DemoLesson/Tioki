class AddCreatedIdToConnectionInvite < ActiveRecord::Migration
  def change
    add_column :connection_invites, :created_user_id, :integer
  end
end
