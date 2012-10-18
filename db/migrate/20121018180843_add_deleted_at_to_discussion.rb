class AddDeletedAtToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :deleted_at, :datetime
  end
end
