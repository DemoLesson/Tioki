class CreatePresentations < ActiveRecord::Migration
  def change
    create_table :presentations do |t|
      t.string :title
      t.string :url
      t.string :location
      t.datetime :date
      t.string :author
      t.string :description
      t.integer :teacher_id

      t.timestamps
    end
  end
end
