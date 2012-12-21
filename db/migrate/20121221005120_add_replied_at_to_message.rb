class AddRepliedAtToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :replied_at, :datetime
  end
end
