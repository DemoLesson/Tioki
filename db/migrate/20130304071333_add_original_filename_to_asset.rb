class AddOriginalFilenameToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :original_filename, :string
  end
end
