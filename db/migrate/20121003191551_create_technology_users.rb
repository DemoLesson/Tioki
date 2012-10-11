class CreateTechnologyUsers < ActiveRecord::Migration
  def change
    create_table :technology_users do |t|
      t.integer :user_id
      t.integer :technology_id

      t.timestamps
    end
  end
end
