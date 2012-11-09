class AddFacebookToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :facebook, :string
  end
end
