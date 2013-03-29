class AddMiscToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :misc, :text
  end
end
