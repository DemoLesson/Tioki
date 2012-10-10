class AddFacebookToTechnology < ActiveRecord::Migration
  def change
    add_column :technologies, :facebook, :string
  end
end
