class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.string :title
      t.string :issuer
      t.datetime :date
      t.string :description
      t.integer :teacher_id

      t.timestamps
    end
  end
end
