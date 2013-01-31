class AddNotificationSentToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :notification_sent, :boolean, :default => false
  end
end
