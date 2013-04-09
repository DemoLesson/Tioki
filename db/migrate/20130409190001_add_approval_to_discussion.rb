class AddApprovalToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :approval, :boolean, :default => false
  end
end
