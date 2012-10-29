class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
      t.integer :user_id
      t.integer :notifiable_id

      t.timestamps
    end
  end
end
