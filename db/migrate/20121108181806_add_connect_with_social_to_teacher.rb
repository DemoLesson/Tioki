class AddConnectWithSocialToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :facebook_connect, :boolean, :default => false
    add_column :teachers, :twitter_connect, :boolean, :default => false
    add_column :teachers, :tweet_about, :boolean, :default => false
  end
end
