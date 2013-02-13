class AddOwnerToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :owner_type, :string
    add_column :assets, :owner_id, :integer
  end
end
