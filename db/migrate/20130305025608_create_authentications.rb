class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :service
      t.integer :user_id
      t.integer :unique_identifier

      t.timestamps
    end
  end
end
