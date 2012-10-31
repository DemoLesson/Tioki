class AddLinksToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :site, :string
    add_column :groups, :twitter, :string
  end
end
