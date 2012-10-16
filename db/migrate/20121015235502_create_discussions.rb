class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title
      t.text :message
      t.integer :user_id

      t.timestamps
    end
  end
end
