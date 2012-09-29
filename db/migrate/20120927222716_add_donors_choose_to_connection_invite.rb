class AddDonorsChooseToConnectionInvite < ActiveRecord::Migration
  def change
    add_column :connection_invites, :donors_choose, :boolean, :default => true
  end
end
