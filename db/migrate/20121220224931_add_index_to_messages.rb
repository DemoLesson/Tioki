class AddIndexToMessages < ActiveRecord::Migration
  def change
		add_index :messages, :user_id_to, :name => "index_messages_on_user_id_to"
		add_index :messages, :user_id_from, :name => "index_messages_on_user_id_from"
		add_index :messages, :replied_to_id, :name => "index_messages_on_replied_to_id"
  end
end
