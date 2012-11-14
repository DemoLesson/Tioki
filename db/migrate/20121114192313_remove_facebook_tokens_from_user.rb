class RemoveFacebookTokensFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :facebook_oauth_token_token
    remove_column :users, :facebook_oauth_secret
  end

  def down
    add_column :users, :facebook_oauth_secret, :string
    add_column :users, :facebook_oauth_token_token, :string
  end
end
