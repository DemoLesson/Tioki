class AddSocialToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :social, :text
  end
end
