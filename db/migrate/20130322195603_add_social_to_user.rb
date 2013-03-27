class AddSocialToUser < ActiveRecord::Migration
  def change
    add_column :users, :social, :text
  end
end
