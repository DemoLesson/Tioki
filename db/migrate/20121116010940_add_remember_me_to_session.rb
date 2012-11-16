class AddRememberMeToSession < ActiveRecord::Migration
  def up
  	add_column :sessions, :remember, :integer
  end

  def down
  	remove_column :session, :remember
  end
end
