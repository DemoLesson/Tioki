class AddContactToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :contact, :text
  end
end
