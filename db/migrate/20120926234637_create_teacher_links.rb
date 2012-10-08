class CreateTeacherLinks < ActiveRecord::Migration
  def change
    create_table :teacher_links do |t|
      t.integer :teacher_id
      t.string :url
      t.integer :type
      t.string :name

      t.timestamps
    end
  end
end
